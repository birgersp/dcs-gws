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
-- @type bajas.ZoneState
-- @field #number value
bajas.ZoneState = {}
bajas.ZoneState.__index = bajas.ZoneState

---
-- @param #bajas.ZoneState self
-- @param #number value
function bajas.ZoneState:new(value)
  self = setmetatable({}, bajas.ZoneState)
  self.value = value
  return self
end

---
-- @type bajas.TaskZone
-- @field #string name
-- @field #bajas.ZoneState status
bajas.TaskZone = {}
bajas.TaskZone.__index = bajas.TaskZone

---
-- @param #bajas.TaskZone self
-- @param #string name
-- @return #bajas.TaskZone
function bajas.TaskZone:new(name)
  self = setmetatable({}, bajas.TaskZone)
  self.name = name
  self.status = bajas.zoneState.CONTESTED
  return self
end

---
-- @param #bajas.TaskZone self
function bajas.TaskZone:updateStatus()
  local redVehicles = mist.makeUnitTable({'[red][vehicle]'})
  local blueVehicles = mist.makeUnitTable({'[blue][vehicle]'})

  local newStatus = self.status
  if #mist.getUnitsInZones(redVehicles, { self.name }) > 0 then
    newStatus = bajas.zoneState.RED
  end

  if #mist.getUnitsInZones(blueVehicles, { self.name }) > 0 then
    if newStatus == bajas.zoneState.RED then
      newStatus = bajas.zoneState.CONTESTED
    else
      newStatus = bajas.zoneState.BLUE
    end
  end

  if newStatus ~= self.status then
    self.status = newStatus
  end
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

-- Task force

---
-- @type bajas.TaskForce
-- @field #number country
-- @field #string spawnZone
-- @field #list<#bajas.UnitSpec> unitSpecs
-- @field #list<#bajas.TaskZone> taskZones
-- @field #list<DCSGroup#Group> groups
bajas.TaskForce = {}
bajas.TaskForce.__index = bajas.TaskForce

---
-- @param #bajas.TaskForce self
-- @param #number country
-- @param #string spawnZoneName
-- @return #bajas.TaskForce
function bajas.TaskForce:new(country, spawnZoneName, taskZoneNames)
  self = setmetatable({}, bajas.TaskForce)
  self.country = country
  self.spawnZone = spawnZoneName
  self.unitSpecs = {}
  self.taskZones = {}
  for i=1, #taskZoneNames do
    self.taskZones[i] = bajas.TaskZone:new(taskZoneNames[i])
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
      local spawnZone = trigger.misc.getZone(self.spawnZone)
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
          ["skill"] = "Excellent",
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
      bajas.debug("!")
    end
  end
end

---
-- @param #bajas.TaskForce self
function bajas.TaskForce:cleanGroups()
  local newGroups = {}
  for i=1, #self.groups do
    local group = self.groups[i]
    if group:isExist() then
      newGroups[#newGroups+1] = group
    end
  end
  self.groups = newGroups
end

---
-- @param #bajas.TaskForce self
-- @param #string zoneName
function bajas.TaskForce:advanceTo(zoneName)
  local groups = self.groups
  for i=1, #groups do
    local destinationZone = trigger.misc.getZone(zoneName)
    local destinationZonePos2 = {
      x = destinationZone.point.x,
      y = destinationZone.point.z
    }
    local randomPointVars = {
      group = Group.getByName(groups[i]:getName()),
      point = destinationZonePos2,
      radius = destinationZone.radius,
      speed = 100,
      disableRoads = true
    }
    mist.groupToRandomPoint(randomPointVars)
  end
end

---
-- @param #bajas.TaskForce self
function bajas.TaskForce:advance()
  local issued = false
  local taskZoneI = 1

  self:cleanGroups()
  while taskZoneI <= #self.taskZones and issued == false do
    local taskZone = self.taskZones[taskZoneI]
    taskZone:updateStatus()
    if coalition.getCountryCoalition(self.country) ~= taskZone.status.value then
      self:advanceTo(taskZone.name)
      issued = true
    end
    taskZoneI = taskZoneI + 1
  end

  if issued == false then
    self:advanceTo(taskZone.name)
  end
end

---
-- @param #bajas.TaskForce self
-- @param #number timeIntervalSec
-- @return #number
function bajas.TaskForce:enableAdvanceInterval(timeIntervalSec)
  local function advance()
    self:advance()
  end

  -- Give it a couple of seconds before initial advance
  return mist.scheduleFunction(advance,nil, timer.getTime()+3, timeIntervalSec)
end

---
-- @param #bajas.TaskForce self
-- @param #number timeIntervalSec
-- @return #number
function bajas.TaskForce:enableReinforceInterval(timeIntervalSec)
  local function reinforce()
    self:reinforce()
  end

  return mist.scheduleFunction(reinforce,nil, timer.getTime()+1, timeIntervalSec)
end

-- Utility function definitions

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

  mist.scheduleFunction(checkTrigger, nil, timer.getTime()+1, 1)

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

  local dir = mist.utils.getDir(mist.vec.sub(midPoint, groupUnitPos))
  local cardinalDir = bajas.radToCardinalDir(dir)
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

  text = text .. " located " .. distanceKM .. "km " .. cardinalDir
  trigger.action.outTextForGroup(group:getID(), text, 30)

end

function bajas.enableIOCEVForGroups()
  local function callback(name)
    local group = Group.getByName(name)
    bajas.informOfClosestEnemyVehicles(group)
  end

  local function addCommandForGroups(groups)
    for i=1, #groups do
      bajas.registerGroupCommand(groups[i]:getName(), bajas.IOCEV_COMMAND_TEXT, callback)
    end
  end

  addCommandForGroups(coalition.getGroups(1))
  addCommandForGroups(coalition.getGroups(2))
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
function bajas.debug(variable, t)
  bajas.printIngame(bajas.toString(variable), t)
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
        str = ""..obj
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
bajas.IOCEV_COMMAND_TEXT = "Request location of closest enemy vehicles"
bajas.zoneState = {
  CONTESTED = bajas.ZoneState:new(coalition.side.NEUTRAL),
  RED = bajas.ZoneState:new(coalition.side.RED),
  BLUE = bajas.ZoneState:new(coalition.side.BLUE)
}

-- Counters
bajas.lastCreatedUnitId = 0
bajas.lastCreatedGroupId = 0
