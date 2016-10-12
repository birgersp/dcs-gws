-- Namespace declaration

mint = {}

-- Type definitions

---
-- @type mint.UnitCluster
-- @field #list<#string> unitNames
-- @field DCSTypes#Vec2 midPoint 
mint.UnitCluster = {}
mint.UnitCluster.__index = mint.UnitCluster

---
-- @param #mint.UnitCluster self
-- @return #mint.UnitCluster
function mint.UnitCluster:new()
  local self = setmetatable({}, mint.UnitCluster)
  self.unitNames = {}
  self.midPoint = {}
  return self
end

---
-- @type mint.UnitSpec
-- @field #number count
-- @field #string type
mint.UnitSpec = {}
mint.UnitSpec.__index = mint.UnitSpec

---
-- @param #mint.UnitSpec self
-- @param #number count
-- @param #string type
-- @return #mint.UnitSpec
function mint.UnitSpec:new(count, type)
  self = setmetatable({}, mint.UnitSpec)
  self.count = count
  self.type = type
  return self
end

---
-- @type mint.ControlZone
-- @field #string name
-- @field #number coalition
mint.ControlZone = {}
mint.ControlZone.__index = mint.ControlZone

---
-- @param #mint.ControlZone self
-- @param #string name
-- @return #mint.ControlZone
function mint.ControlZone:new(name)
  self = setmetatable({}, mint.ControlZone)
  self.name = name
  self.coalition = coalition.side.NEUTRAL
  return self
end

---
-- @type mint.TaskForce
-- @field #number country
-- @field #list<#string> spawnZones
-- @field #list<#mint.ControlZone> controlZones
-- @field #list<#mint.UnitSpec> unitSpecs
-- @field #list<DCSGroup#Group> groups
-- @field #string target
mint.TaskForce = {}
mint.TaskForce.__index = mint.TaskForce

---
-- @param #mint.TaskForce self
-- @param #number country
-- @param #list<#string> spawnZones
-- @param #list<#string> controlZones
-- @return #mint.TaskForce
function mint.TaskForce:new(country, spawnZones, controlZones)
  self = setmetatable({}, mint.TaskForce)
  self.country = country
  self.spawnZones = spawnZones
  self.unitSpecs = {}
  self.controlZones = {}
  for i=1, #controlZones do
    local controlZone = controlZones[i]
    self.controlZones[#self.controlZones + 1] = mint.ControlZone:new(controlZone)
  end
  self.groups = {}
  return self
end

---
-- @param #mint.TaskForce self
-- @param #number count
-- @param #string type
function mint.TaskForce:addUnitSpec(count, type)
  self.unitSpecs[#self.unitSpecs+1] = mint.UnitSpec:new(count, type)
end

---
-- @param #mint.TaskForce self
function mint.TaskForce:cleanGroups()
  local newGroups = {}
  for i=1, #self.groups do
    local group = self.groups[i]
    if #group:getUnits() > 0 then newGroups[#newGroups+1] = group end
  end
  self.groups = newGroups
end

---
-- @param #mint.TaskForce self
function mint.TaskForce:reinforce()
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
      replacements = replacements - mint.countUnitsOfType(self.groups[groupIndex]:getUnits(),unitSpec.type)
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
          ["name"] = "Unit no " .. mint.lastCreatedUnitId,
          ["unitId"] = mint.lastCreatedUnitId,
          ["skill"] = "High",
          ["playerCanDrive"] = true
        }
        spawnedUnitCount = spawnedUnitCount + 1

        mint.lastCreatedUnitId = mint.lastCreatedUnitId + 1
      end

      local groupName = "Group #00" .. mint.lastCreatedGroupId
      local groupData = {
        ["route"] = {},
        ["groupId"] = mint.lastCreatedGroupId,
        ["units"] = units,
        ["name"] = groupName
      }

      coalition.addGroup(self.country, Group.Category.GROUND, groupData)
      mint.lastCreatedGroupId = mint.lastCreatedGroupId + 1
      self.groups[#self.groups+1] = Group.getByName(groupName)
      if self.target ~= nil then
        mint.issueGroupTo(groupName, self.target)
      end
    end
  end
end

---
-- @param #mint.TaskForce self
function mint.TaskForce:updateTarget()
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
-- @param #mint.TaskForce self
-- @param #string zone
function mint.TaskForce:issueTo(zone)
  self:cleanGroups()
  for i=1, #self.groups do
    mint.issueGroupTo(self.groups[i]:getName(), self.target)
  end
end

---
-- @param #mint.TaskForce self
function mint.TaskForce:issueToTarget()
  self:issueTo(self.target)
end

---
-- @param #mint.TaskForce self
-- @param #number timeIntervalSec
-- @return #number
function mint.TaskForce:enableAutoIssue(timeIntervalSec)
  local function autoIssue()
    self:updateTarget()
    self:issueToTarget()
  end

  -- Give it a couple of seconds before initial advance
  return mist.scheduleFunction(autoIssue, nil, timer.getTime()+2, timeIntervalSec)
end

---
-- @param #mint.TaskForce self
-- @param #number timeIntervalSec
-- @return #number
function mint.TaskForce:enableAutoReinforce(timeIntervalSec)
  local function reinforce()
    self:reinforce()
  end

  return mist.scheduleFunction(reinforce,nil, timer.getTime()+1, timeIntervalSec)
end

---
-- @param #mint.TaskForce self
function mint.TaskForce:enableDefault()
  self:enableAutoIssue(mint.DEFAULT_AUTO_ISSUE_DELAY)
  self:enableAutoReinforce(mint.DEFAULT_AUTO_REINFORCE_DELAY)
end

-- Utility function definitions

---
-- @param #string groupName
-- @param #string zoneName
function mint.issueGroupTo(groupName, zoneName)
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
function mint.countUnitsOfType(units, type)
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
function mint.registerGroupCommand(groupName, commandName, callback)

  local group = Group.getByName(groupName)
  local groupId = group:getID()
  local flagName = mint.GROUP_COMMAND_FLAG_NAME..groupId
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
function mint.getDistanceBetween(a, b)
  local dx = a.x - b.x
  local dy = a.y - b.y
  local dz = a.z - b.z
  return math.sqrt(dx*dx + dy*dy + dz*dz)
end

---
-- @param #string unitName
-- @return DCSUnit#Unit
function mint.getClosestEnemyVehicle(unitName)

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
    local closestEnemyDistance = mint.getDistanceBetween(unitPosition, enemyUnitPosition)
    local newClosestEnemy = {}
    local newClosestEnemyDistance = 0
    for i=2, #enemyVehicles do
      newClosestEnemy = Unit.getByName(enemyVehicles[i])
      newClosestEnemyDistance = mint.getDistanceBetween(unitPosition, newClosestEnemy:getPosition().p)
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
function mint.radToCardinalDir(rad)

  local dirNormalized = rad / math.pi / 2
  local i = 1
  if dirNormalized < (#mint.CARDINAL_DIRECTIONS-1) / #mint.CARDINAL_DIRECTIONS then
    while dirNormalized > i/#mint.CARDINAL_DIRECTIONS/2 do
      i = i+2
    end
  end
  local index = math.floor(i/2) + 1
  return mint.CARDINAL_DIRECTIONS[index]
end

---
--This function might be computationally expensive
-- @param DCSUnit#Unit unit
-- @param #number radius
-- @return #mint.UnitCluster
function mint.getFriendlyVehiclesWithin(unit, radius)
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
        if mint.getDistanceBetween(targetUnit:getPosition().p,nextUnit:getPosition().p) <= radius then
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

  local result = mint.UnitCluster:new()
  result.unitNames = addedVehiclesNames
  result.midPoint = midPoint
  return result

end

---
--Prints out a message to a group, describing nearest enemy vehicles
-- @param DCSGroup#Group group
function mint.informOfClosestEnemyVehicles(group)

  local firstGroupUnit = group:getUnit(1)
  local closestEnemy = mint.getClosestEnemyVehicle(firstGroupUnit:getName())
  local groupUnitPos = {
    x = firstGroupUnit:getPosition().p.x,
    y = 0,
    z = firstGroupUnit:getPosition().p.z
  }

  local enemyCluster = mint.getFriendlyVehiclesWithin(closestEnemy,mint.MAX_CLUSTER_DISTANCE)
  local midPoint = mist.utils.makeVec3(enemyCluster.midPoint)

  local dirRad = mist.utils.getDir(mist.vec.sub(midPoint, groupUnitPos))
  local dirDegree = math.floor(dirRad / math.pi * 18 + 0.5) * 10 -- Rounded to nearest 10
  --  local cardinalDir = mint.radToCardinalDir(dirRad)
  local distance = mint.getDistanceBetween(midPoint, groupUnitPos)
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

function mint.enableIOCEVForGroups()
  local function callback(name)
    local group = Group.getByName(name)
    mint.informOfClosestEnemyVehicles(group)
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
        trigger.action.removeOtherCommandForGroup(group:getID(), mint.IOCEV_COMMAND_TEXT)
        functionIDS[#functionIDS + 1] = mint.registerGroupCommand(group:getName(), mint.IOCEV_COMMAND_TEXT, callback)
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
function mint.deepCopy(t)
  if type(t) ~= "table" then return t end
  local meta = getmetatable(t)
  local target = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      target[k] = mint.deepCopy(v)
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
function mint.printIngame(str, time)
  if (time == nil) then
    time = 1
  end
  trigger.action.outText(str, time)
end

---
function mint.debug(variable)
  mint.printIngame(mint.toString(variable))
end

---
-- Returns a string representation of an object
function mint.toString(obj)

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

mint.GROUP_COMMAND_FLAG_NAME = "groupCommandTrigger"
mint.CARDINAL_DIRECTIONS = {"N", "N/NE", "NE", "NE/E", "E", "E/SE", "SE", "SE/S", "S", "S/SW", "SW", "SW/W", "W", "W/NW", "NW", "NW/N"}
mint.MAX_CLUSTER_DISTANCE = 1000
mint.IOCEV_COMMAND_TEXT = "Request location of enemy vehicles"
mint.DEFAULT_AUTO_ISSUE_DELAY = 300
mint.DEFAULT_AUTO_REINFORCE_DELAY = 600

-- Counters
mint.lastCreatedUnitId = 0
mint.lastCreatedGroupId = 0
