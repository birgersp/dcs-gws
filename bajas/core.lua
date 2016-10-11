-- Namespace declaration

bajas = {}

-- Type definitions

---
-- @type bajas.UnitCluster
-- @field #list<#string> unitNames
-- @field DCSTypes#Vec2 midPoint
bajas.UnitCluster = {}
bajas.UnitCluster.__index = bajas.UnitCluster

---
-- @param #bajas.UnitCluster self
-- @return #bajas.UnitCluster
function bajas.UnitCluster:new()
  local self = setmetatable({}, bajas.UnitCluster)
  self.unitNames = {}
  self.midPoint = {}
  return self
end

---
-- @type bajas.UnitSpec
-- @field #number count
-- @field #string type
bajas.UnitSpec = {}
bajas.UnitSpec.__index = bajas.UnitSpec

---
-- @param #bajas.UnitSpec self
-- @param #number count
-- @param #string type
-- @return #bajas.UnitSpec
function bajas.UnitSpec:new(count, type)
  self = setmetatable({}, bajas.UnitSpec)
  self.count = count
  self.type = type
  return self
end

---
-- @type bajas.ControlZone
-- @field #string name
-- @field #number coalition
bajas.ControlZone = {}
bajas.ControlZone.__index = bajas.ControlZone

---
-- @param #bajas.ControlZone self
-- @param #string name
-- @return #bajas.ControlZone
function bajas.ControlZone:new(name)
  self = setmetatable({}, bajas.ControlZone)
  self.name = name
  self.coalition = coalition.side.NEUTRAL
  return self
end

---
-- @type bajas.TaskForce
-- @field #number country
-- @field #list<#string> spawnZones
-- @field #list<#bajas.ControlZone> controlZones
-- @field #list<#bajas.UnitSpec> unitSpecs
-- @field #list<DCSGroup#Group> groups
-- @field #string target
bajas.TaskForce = {}
bajas.TaskForce.__index = bajas.TaskForce

---
-- @param #bajas.TaskForce self
-- @param #number country
-- @param #list<#string> spawnZones
-- @param #list<#string> controlZones
-- @return #bajas.TaskForce
function bajas.TaskForce:new(country, spawnZones, controlZones)
  self = setmetatable({}, bajas.TaskForce)
  self.country = country
  self.spawnZones = spawnZones
  self.unitSpecs = {}
  self.controlZones = {}
  for i=1, #controlZones do
    local controlZone = controlZones[i]
    self.controlZones[#self.controlZones + 1] = bajas.ControlZone:new(controlZone)
  end
  self.groups = {}
  return self
end

---
-- @param #bajas.TaskForce self
-- @param #number count
-- @param #string type
function bajas.TaskForce:addUnitSpec(count, type)
  self.unitSpecs[#self.unitSpecs+1] = bajas.UnitSpec:new(count, type)
end

---
-- @param #bajas.TaskForce self
function bajas.TaskForce:cleanGroups()
  local newGroups = {}
  for i=1, #self.groups do
    local group = self.groups[i]
    if #group:getUnits() > 0 then newGroups[#newGroups+1] = group end
  end
  self.groups = newGroups
end

---
-- @param #bajas.TaskForce self
function bajas.TaskForce:reinforce()
  local spawnedUnitCount = 0
  self:cleanGroups()
  local desiredUnits = {}
  for i=1, #self.unitSpecs do
    local unitSpec = self.unitSpecs[i]
    if desiredUnits[unitSpec.type] == nil then
      desiredUnits[unitSpec.type] = 0
    end

    desiredUnits[unitSpec.type] = desiredUnits[unitSpec.type] + unitSpec.count
    local replacements = desiredUnits[unitSpec.type]
    for groupIndex=1, #self.groups do
      replacements = replacements - bajas.countUnitsOfType(self.groups[groupIndex]:getUnits(),unitSpec.type)
    end

    if replacements > 0 then
      local units = {}
      local spawnZoneIndex = math.random(#self.spawnZones)
      local spawnZone = trigger.misc.getZone(self.spawnZones[spawnZoneIndex])
      for i = 1, replacements do
        units[i] = {
          ["type"] = unitSpec.type,
          ["transportable"] =
          {
            ["randomTransportable"] = false,
          },
          ["x"] = spawnZone.point.x + 15*spawnedUnitCount,
          ["y"] = spawnZone.point.z - 15*spawnedUnitCount,
          ["name"] = "Unit no " .. bajas.lastCreatedUnitId,
          ["unitId"] = bajas.lastCreatedUnitId,
          ["skill"] = "High",
          ["playerCanDrive"] = true
        }
        spawnedUnitCount = spawnedUnitCount + 1

        bajas.lastCreatedUnitId = bajas.lastCreatedUnitId + 1
      end

      local groupName = "Group #00" .. bajas.lastCreatedGroupId
      local groupData = {
        ["route"] = {},
        ["groupId"] = bajas.lastCreatedGroupId,
        ["units"] = units,
        ["name"] = groupName
      }

      coalition.addGroup(self.country, Group.Category.GROUND, groupData)
      bajas.lastCreatedGroupId = bajas.lastCreatedGroupId + 1
      self.groups[#self.groups+1] = Group.getByName(groupName)
      if self.target ~= nil then
        bajas.issueGroupTo(groupName, self.target)
      end
    end
  end
end

---
-- @param #bajas.TaskForce self
function bajas.TaskForce:updateTarget()
  local redVehicles = mist.makeUnitTable({'[red][vehicle]'})
  local blueVehicles = mist.makeUnitTable({'[blue][vehicle]'})

  local done = false
  local zoneIndex = 1
  while done == false and zoneIndex <= #self.controlZones do
    local zone = self.controlZones[zoneIndex]
    local newStatus = nil
    if #mist.getUnitsInZones(redVehicles, {zone.name}) > 0 then
      newStatus = coalition.side.RED
    end

    if #mist.getUnitsInZones(blueVehicles, {zone.name}) > 0 then
      if newStatus == coalition.side.RED then
        newStatus = coalition.side.NEUTRAL
      else
        newStatus = coalition.side.BLUE
      end
    end

    if newStatus ~= nil then
      zone.status = newStatus
    end

    if zone.status ~= coalition.getCountryCoalition(self.country) then
      self.target = zone.name
      done = true
    end
    zoneIndex = zoneIndex + 1
  end

  if self.target == nil then
    self.target = self.controlZones[#self.controlZones].name
  end
end

---
-- @param #bajas.TaskForce self
-- @param #string zone
function bajas.TaskForce:issueTo(zone)
  self:cleanGroups()
  for i=1, #self.groups do
    bajas.issueGroupTo(self.groups[i]:getName(), self.target)
  end
end

---
-- @param #bajas.TaskForce self
function bajas.TaskForce:issueToTarget()
  self:issueTo(self.target)
end

---
-- @param #bajas.TaskForce self
-- @param #number timeIntervalSec
-- @return #number
function bajas.TaskForce:enableAutoIssue(timeIntervalSec)
  local function autoIssue()
    self:updateTarget()
    self:issueToTarget()
  end

  -- Give it a couple of seconds before initial advance
  return mist.scheduleFunction(autoIssue, nil, timer.getTime()+2, timeIntervalSec)
end

---
-- @param #bajas.TaskForce self
-- @param #number timeIntervalSec
-- @return #number
function bajas.TaskForce:enableAutoReinforce(timeIntervalSec)
  local function reinforce()
    self:reinforce()
  end

  return mist.scheduleFunction(reinforce,nil, timer.getTime()+1, timeIntervalSec)
end


-- Utility function definitions

---
-- @param #string groupName
-- @param #string zoneName
function bajas.issueGroupTo(groupName, zoneName)
  local destinationZone = trigger.misc.getZone(zoneName)
  local destinationZonePos2 = {
    x = destinationZone.point.x,
    y = destinationZone.point.z
  }
  local randomPointVars = {
    group = Group.getByName(groupName),
    point = destinationZonePos2,
    radius = destinationZone.radius,
    speed = 100,
    disableRoads = true
  }
  mist.groupToRandomPoint(randomPointVars)
end

---
-- @param #list<DCSUnit#Unit> units
-- @param #string type
-- @return #number
function bajas.countUnitsOfType(units, type)
  local count=0
  local unit
  for i=1, #units do
    if units[i]:getTypeName() == type then
      count = count+1
    end
  end
  return count
end

---
-- @param #number groupName
-- @param #string commandName
-- @param #function callback
-- @return #number ID of scheduled function
function bajas.registerGroupCommand(groupName, commandName, callback)

  local group = Group.getByName(groupName)
  local groupId = group:getID()
  local flagName = bajas.GROUP_COMMAND_FLAG_NAME..groupId
  trigger.action.setUserFlag(flagName, 0)
  trigger.action.addOtherCommandForGroup(groupId, commandName, flagName, 1)

  local function checkTrigger()
    if (trigger.misc.getUserFlag(flagName) == 1) then
      trigger.action.setUserFlag(flagName, 0)
      callback(groupName)
    end
  end

  return mist.scheduleFunction(checkTrigger, nil, timer.getTime()+1, 1)

end

---
-- @param #vec3
-- @param #vec3
-- @return #number
function bajas.getDistanceBetween(a, b)
  local dx = a.x - b.x
  local dy = a.y - b.y
  local dz = a.z - b.z
  return math.sqrt(dx*dx + dy*dy + dz*dz)
end

---
-- @param #string unitName
-- @return DCSUnit#Unit
function bajas.getClosestEnemyVehicle(unitName)

  local unit = Unit.getByName(unitName)
  local unitPosition = unit:getPosition().p
  local enemyUnitPosition = {}
  local enemyCoalitionString = "[red]"
  if unit:getCoalition() == 1 then
    enemyCoalitionString = "[blue]"
  end
  local unitTableStr = enemyCoalitionString .. '[vehicle]'
  local enemyVehicles = mist.makeUnitTable({ unitTableStr })
  if #enemyVehicles > 0 then
    local closestEnemy = Unit.getByName(enemyVehicles[1])
    enemyUnitPosition = closestEnemy:getPosition().p
    local closestEnemyDistance = bajas.getDistanceBetween(unitPosition, enemyUnitPosition)
    local newClosestEnemy = {}
    local newClosestEnemyDistance = 0
    for i=2, #enemyVehicles do
      newClosestEnemy = Unit.getByName(enemyVehicles[i])
      newClosestEnemyDistance = bajas.getDistanceBetween(unitPosition, newClosestEnemy:getPosition().p)
      if (newClosestEnemyDistance < closestEnemyDistance) then
        closestEnemy = newClosestEnemy
      end
    end
    return closestEnemy
  end
end

---
-- @param #number rad Direction in radians
-- @return #string A string representing a cardinal direction
function bajas.radToCardinalDir(rad)

  local dirNormalized = rad / math.pi / 2
  local i = 1
  if dirNormalized < (#bajas.CARDINAL_DIRECTIONS-1) / #bajas.CARDINAL_DIRECTIONS then
    while dirNormalized > i/#bajas.CARDINAL_DIRECTIONS/2 do
      i = i+2
    end
  end
  local index = math.floor(i/2) + 1
  return bajas.CARDINAL_DIRECTIONS[index]
end

---
--This function might be computationally expensive
-- @param DCSUnit#Unit unit
-- @param #number radius
-- @return #bajas.UnitCluster
function bajas.getFriendlyVehiclesWithin(unit, radius)
  local coalitionString
  if unit:getCoalition() == coalition.side.BLUE then
    coalitionString = "[blue]"
  else
    coalitionString  = "[red]"
  end
  local unitTableStr = coalitionString .. '[vehicle]'
  local units = mist.makeUnitTable({ unitTableStr })

  local addedVehiclesNames = {unit:getName()}
  local minPos = unit:getPosition().p
  local maxPos = unit:getPosition().p

  ---
  -- @param #list list
  -- @param value
  local function contains(list, value)
    for i=1, #list do
      if list[i] == value then
        return true
      end
    end
    return false
  end

  ---
  -- @param DCSUnit#Unit unit
  local function addUnit(unit)
    local pos = unit:getPosition().p
    if pos.x < minPos.x then minPos.x = pos.x end
    if pos.z < minPos.z then minPos.z = pos.z end
    if pos.x > maxPos.x then maxPos.x = pos.x end
    if pos.z > maxPos.z then maxPos.z = pos.z end
    addedVehiclesNames[#addedVehiclesNames+1] = unit:getName()
  end

  ---
  -- @param DCSUnit#Unit unit
  local function vehiclesWithinRecurse(targetUnit)
    for i=1, #units do
      local nextUnit = Unit.getByName(units[i])
      if nextUnit:getID() == targetUnit:getID() == false then
        if bajas.getDistanceBetween(targetUnit:getPosition().p,nextUnit:getPosition().p) <= radius then
          if contains(addedVehiclesNames, nextUnit:getName()) == false then
            addUnit(nextUnit)
            vehiclesWithinRecurse(nextUnit)
          end
        end
      end
    end
  end

  vehiclesWithinRecurse(unit)

  local dx = maxPos.x - minPos.x
  local dz = maxPos.z - minPos.z

  local midPoint = { -- 3D to 2D conversion implemented
    x = minPos.x + dx / 2,
    y = minPos.z + dz / 2
  }

  local result = bajas.UnitCluster:new()
  result.unitNames = addedVehiclesNames
  result.midPoint = midPoint
  return result

end

---
--Prints out a message to a group, describing nearest enemy vehicles
-- @param DCSGroup#Group group
function bajas.informOfClosestEnemyVehicles(group)

  local firstGroupUnit = group:getUnit(1)
  local closestEnemy = bajas.getClosestEnemyVehicle(firstGroupUnit:getName())
  local groupUnitPos = {
    x = firstGroupUnit:getPosition().p.x,
    y = 0,
    z = firstGroupUnit:getPosition().p.z
  }

  local enemyCluster = bajas.getFriendlyVehiclesWithin(closestEnemy,bajas.MAX_CLUSTER_DISTANCE)
  local midPoint = mist.utils.makeVec3(enemyCluster.midPoint)

  local dirRad = mist.utils.getDir(mist.vec.sub(midPoint, groupUnitPos))
  local dirDegree = math.floor(dirRad / math.pi * 18 + 0.5) * 10 -- Rounded to nearest 10
  --  local cardinalDir = bajas.radToCardinalDir(dirRad)
  local distance = bajas.getDistanceBetween(midPoint, groupUnitPos)
  local distanceKM = math.floor(distance / 1000 + 0.5)

  local vehicleTypes = {}
  for i=1, #enemyCluster.unitNames do
    local type = Unit.getByName(enemyCluster.unitNames[i]):getTypeName()
    if vehicleTypes[type] == nil then
      vehicleTypes[type] = 0
    end

    vehicleTypes[type] = vehicleTypes[type] + 1
  end

  local text = ""
  for key,val in pairs(vehicleTypes) do
    if (text ~= "") then
      text = text..", "
    end
    text = text..val.." "..key
  end

  text = text .. " located " .. distanceKM .. "km at ~" .. dirDegree
  trigger.action.outTextForGroup(group:getID(), text, 30)

end

function bajas.enableIOCEVForGroups()
  local function callback(name)
    local group = Group.getByName(name)
    bajas.informOfClosestEnemyVehicles(group)
  end

  local functionIDS = {}
  local function enableForAll()
  
    -- Disable timers from previous enable
    for i=1, #functionIDS do
      mist.removeFunction(functionIDS[i])
    end
    functionIDS = {}

    -- Re-enable command for all groups
    local function enableForGroups(groups)
      for i=1, #groups do
        local group = groups[i]
        trigger.action.removeOtherCommandForGroup(group:getID(), bajas.IOCEV_COMMAND_TEXT)
        functionIDS[#functionIDS + 1] = bajas.registerGroupCommand(group:getName(), bajas.IOCEV_COMMAND_TEXT, callback)
      end
    end

    enableForGroups(coalition.getGroups(1))
    enableForGroups(coalition.getGroups(2))
  end

  mist.scheduleFunction(enableForAll,nil,timer.getTime() + 1, 30)
end

---
-- Deep copy a table
--Code from https://gist.github.com/MihailJP/3931841
function bajas.deepCopy(t)
  if type(t) ~= "table" then return t end
  local meta = getmetatable(t)
  local target = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      target[k] = bajas.deepCopy(v)
    else
      target[k] = v
    end
  end
  setmetatable(target, meta)
  return target
end

---
-- @param #string str
-- @param #number time
function bajas.printIngame(str, time)
  if (time == nil) then
    time = 1
  end
  trigger.action.outText(str, time)
end

---
function bajas.debug(variable)
  bajas.printIngame(bajas.toString(variable))
end

---
-- Returns a string representation of an object
function bajas.toString(obj)

  local indent = "    "
  local function toStringRecursively(obj, level)

    if (obj == nil) then
      return "(nil)"
    end

    local str = ""
    if (type(obj) == "table") then
      if (level ~= 0) then
        str = str .. "{"
      end
      local isFirst = true
      for key, value in pairs(obj) do
        if (isFirst == false) then
          str = str .. ","
        end
        str = str .. "\n"
        for i = 1, level do
          str = str .. indent
        end

        if (type(key) == "number") then
          str = str .. "[\"" .. key .. "\"]"
        else
          str = str .. key
        end
        str = str .. " = "

        if (type(value) == "function") then
          str = str .. "(function)"
        else
          str = str .. toStringRecursively(value, level + 1)
        end
        isFirst = false
      end

      if (level ~= 0) then
        str = str .. "\n"
        for i = 1, level - 1 do
          str = str .. indent
        end
        str = str .. "}"
      end
    else
      str = obj
      if (type(obj) == "string") then
        str = "\"" .. str .. "\""
      elseif type(obj) == "boolean" then
        if obj == true then
          str = "true"
        else
          str = "false"
        end
      end
    end

    return str
  end

  return toStringRecursively(obj, 1)
end

-- Constant declarations

bajas.GROUP_COMMAND_FLAG_NAME = "groupCommandTrigger"
bajas.CARDINAL_DIRECTIONS = {"N", "N/NE", "NE", "NE/E", "E", "E/SE", "SE", "SE/S", "S", "S/SW", "SW", "SW/W", "W", "W/NW", "NW", "NW/N"}
bajas.MAX_CLUSTER_DISTANCE = 1000
bajas.IOCEV_COMMAND_TEXT = "Request location of enemy vehicles"

-- Counters
bajas.lastCreatedUnitId = 0
bajas.lastCreatedGroupId = 0
