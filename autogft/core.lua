-- Namespace declaration

autogft = {}

-- Type definitions

---
-- @type autogft.UnitCluster
-- @field #list<#string> unitNames
-- @field DCSTypes#Vec2 midPoint
autogft.UnitCluster = {}
autogft.UnitCluster.__index = autogft.UnitCluster

---
-- @param #autogft.UnitCluster self
-- @return #autogft.UnitCluster
function autogft.UnitCluster:new()
  local self = setmetatable({}, autogft.UnitCluster)
  self.unitNames = {}
  self.midPoint = {}
  return self
end

---
-- @type autogft.UnitSpec
-- @field #number count
-- @field #string type
autogft.UnitSpec = {}
autogft.UnitSpec.__index = autogft.UnitSpec

---
-- @param #autogft.UnitSpec self
-- @param #number count
-- @param #string type
-- @return #autogft.UnitSpec
function autogft.UnitSpec:new(count, type)
  self = setmetatable({}, autogft.UnitSpec)
  self.count = count
  self.type = type
  return self
end

---
-- @type autogft.ControlZone
-- @field #string name
-- @field #number status
autogft.ControlZone = {}
autogft.ControlZone.__index = autogft.ControlZone

---
-- @param #autogft.ControlZone self
-- @param #string name
-- @return #autogft.ControlZone
function autogft.ControlZone:new(name)
  self = setmetatable({}, autogft.ControlZone)
  self.name = name
  self.status = coalition.side.NEUTRAL
  return self
end

---
-- @type autogft.TaskForce
-- @field #number country
-- @field #list<#string> spawnZones
-- @field #list<#autogft.ControlZone> controlZones
-- @field #number speed
-- @field #string formation
-- @field #list<#autogft.UnitSpec> unitSpecs
-- @field #list<DCSGroup#Group> groups
-- @field #string target
autogft.TaskForce = {}
autogft.TaskForce.__index = autogft.TaskForce

---
-- @param #autogft.TaskForce self
-- @param #number country
-- @param #list<#string> spawnZones
-- @param #list<#string> controlZones
-- @return #autogft.TaskForce
function autogft.TaskForce:new(country, spawnZones, controlZones)
  self = setmetatable({}, autogft.TaskForce)
  self.country = country
  self.spawnZones = spawnZones
  self.unitSpecs = {}
  self.controlZones = {}
  self.speed = 100
  self.formation = "cone"
  for i = 1, #controlZones do
    local controlZone = controlZones[i]
    self.controlZones[#self.controlZones + 1] = autogft.ControlZone:new(controlZone)
  end
  self.groups = {}
  self.target = controlZones[1]
  return self
end

---
-- @param #autogft.TaskForce self
-- @param #number count
-- @param #string type
function autogft.TaskForce:addUnitSpec(count, type)
  self.unitSpecs[#self.unitSpecs + 1] = autogft.UnitSpec:new(count, type)
end

---
-- @param #autogft.TaskForce self
function autogft.TaskForce:cleanGroups()
  local newGroups = {}
  for i = 1, #self.groups do
    local group = self.groups[i]
    if #group:getUnits() > 0 then newGroups[#newGroups + 1] = group end
  end
  self.groups = newGroups
end

---
-- @param #autogft.TaskForce self
function autogft.TaskForce:respawn()
  local spawnedUnitCount = 0
  self:cleanGroups()
  local desiredUnits = {}
  for i = 1, #self.unitSpecs do
    local unitSpec = self.unitSpecs[i]
    if desiredUnits[unitSpec.type] == nil then
      desiredUnits[unitSpec.type] = 0
    end

    desiredUnits[unitSpec.type] = desiredUnits[unitSpec.type] + unitSpec.count
    local replacements = desiredUnits[unitSpec.type]
    for groupIndex = 1, #self.groups do
      replacements = replacements - autogft.countUnitsOfType(self.groups[groupIndex]:getUnits(), unitSpec.type)
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
          ["x"] = spawnZone.point.x + 15 * spawnedUnitCount,
          ["y"] = spawnZone.point.z - 15 * spawnedUnitCount,
          ["name"] = "Unit no " .. autogft.lastCreatedUnitId,
          ["unitId"] = autogft.lastCreatedUnitId,
          ["skill"] = "High",
          ["playerCanDrive"] = true
        }
        spawnedUnitCount = spawnedUnitCount + 1

        autogft.lastCreatedUnitId = autogft.lastCreatedUnitId + 1
      end

      local groupName = "Group #00" .. autogft.lastCreatedGroupId
      local groupData = {
        ["route"] = {},
        ["groupId"] = autogft.lastCreatedGroupId,
        ["units"] = units,
        ["name"] = groupName
      }

      coalition.addGroup(self.country, Group.Category.GROUND, groupData)
      autogft.lastCreatedGroupId = autogft.lastCreatedGroupId + 1
      self.groups[#self.groups + 1] = Group.getByName(groupName)
      if self.target ~= nil then
        autogft.issueGroupTo(groupName, self.target)
      end
    end
  end
end

---
-- @param #autogft.TaskForce self
function autogft.TaskForce:updateTarget()
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
-- @param #autogft.TaskForce self
-- @param #string zone
function autogft.TaskForce:issueTo(zone)
  self:cleanGroups()
  for i = 1, #self.groups do
    autogft.issueGroupTo(self.groups[i]:getName(), self.target, self.speed, self.formation)
  end
end

---
-- @param #autogft.TaskForce self
function autogft.TaskForce:moveToTarget()
  self:issueTo(self.target)
end

---
-- @param #autogft.TaskForce self
-- @param #number timeIntervalSec
-- @return #number
function autogft.TaskForce:enableMoveTimer(timeIntervalSec)
  local function autoIssue()
    self:updateTarget()
    self:moveToTarget()
    timer.scheduleFunction(autoIssue, {}, timer.getTime() + timeIntervalSec)
  end

  timer.scheduleFunction(autoIssue, {}, timer.getTime() + timeIntervalSec)
end

---
-- @param #autogft.TaskForce self
-- @param #number timeIntervalSec
-- @param #number maxReinforcementTime (optional)
-- @return #number
function autogft.TaskForce:enableRespawnTimer(timeIntervalSec, maxReinforcementTime)
  local keepReinforcing = true
  local function respawn()
    if keepReinforcing then
      self:respawn()
      timer.scheduleFunction(respawn, {}, timer.getTime() + timeIntervalSec)
    end
  end

  timer.scheduleFunction(respawn, {}, timer.getTime() + timeIntervalSec)

  if maxReinforcementTime ~= nil and maxReinforcementTime > 0 then
    local function killTimer()
      keepReinforcing = false
    end
    timer.scheduleFunction(killTimer, {}, timer.getTime() + maxReinforcementTime)
  end
end

---
-- @param #autogft.TaskForce self
function autogft.TaskForce:enableDefaultTimers()
  self:enableMoveTimer(autogft.DEFAULT_AUTO_ISSUE_DELAY)
  self:enableRespawnTimer(autogft.DEFAULT_AUTO_REINFORCE_DELAY)
end

---
-- @type autogft.GroupCommand
-- @field #string commandName
-- @field #string groupName
-- @field #number groupId
-- @field #function func
-- @field #number timerId
-- @field #boolean enabled
autogft.GroupCommand = {}
autogft.GroupCommand.__index = autogft.GroupCommand

---
-- @param #autogft.GroupCommand self
-- @param #string commandName
-- @param #string groupName
-- @param #function func
-- @return #autogft.GroupCommand
function autogft.GroupCommand:new(commandName, groupName, func)
  self = setmetatable({}, autogft.GroupCommand)
  self.commandName = commandName
  self.groupName = groupName
  self.groupId = Group.getByName(groupName):getID()
  self.func = func
  return self
end

---
-- @param #autogft.GroupCommand self
function autogft.GroupCommand:enable()
  self.enabled = true

  local flagName = autogft.GROUP_COMMAND_FLAG_NAME..self.groupId
  trigger.action.setUserFlag(flagName, 0)
  trigger.action.addOtherCommandForGroup(self.groupId, self.commandName, flagName, 1)

  local function checkTrigger()
    if self.enabled == true then
      if (trigger.misc.getUserFlag(flagName) == 1) then
        trigger.action.setUserFlag(flagName, 0)
        self.func()
      end
      timer.scheduleFunction(checkTrigger, {}, timer.getTime() + 1)
    end
  end
  checkTrigger()
end

---
-- @param #autogft.GroupCommand self
function autogft.GroupCommand:disable()
  -- Remove group command from mission
  trigger.action.removeOtherCommandForGroup(self.groupId, self.commandName)
  self.enabled = false
end

-- Utility function definitions

---
-- @param #string groupName
-- @param #string zoneName
function autogft.issueGroupTo(groupName, zoneName, speed, formation)
  local destinationZone = trigger.misc.getZone(zoneName)
  local destinationZonePos2 = {
    x = destinationZone.point.x,
    y = destinationZone.point.z
  }
  local randomPointVars = {
    group = Group.getByName(groupName),
    point = destinationZonePos2,
    radius = destinationZone.radius,
    speed = speed,
    formation = formation,
    disableRoads = true
  }
  mist.groupToRandomPoint(randomPointVars)
end

---
-- @param #list<DCSUnit#Unit> units
-- @param #string type
-- @return #number
function autogft.countUnitsOfType(units, type)
  local count = 0
  local unit
  for i = 1, #units do
    if units[i]:getTypeName() == type then
      count = count + 1
    end
  end
  return count
end

---
-- @param #vec3
-- @param #vec3
-- @return #number
function autogft.getDistanceBetween(a, b)
  local dx = a.x - b.x
  local dy = a.y - b.y
  local dz = a.z - b.z
  return math.sqrt(dx * dx + dy * dy + dz * dz)
end

---
-- @param #string unitName
-- @return DCSUnit#Unit
function autogft.getClosestEnemyVehicle(unitName)

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
    local closestEnemyDistance = autogft.getDistanceBetween(unitPosition, enemyUnitPosition)
    local newClosestEnemy = {}
    local newClosestEnemyDistance = 0
    for i = 2, #enemyVehicles do
      newClosestEnemy = Unit.getByName(enemyVehicles[i])
      newClosestEnemyDistance = autogft.getDistanceBetween(unitPosition, newClosestEnemy:getPosition().p)
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
function autogft.radToCardinalDir(rad)

  local dirNormalized = rad / math.pi / 2
  local i = 1
  if dirNormalized < (#autogft.CARDINAL_DIRECTIONS-1) / #autogft.CARDINAL_DIRECTIONS then
    while dirNormalized > i/#autogft.CARDINAL_DIRECTIONS/2 do
      i = i + 2
    end
  end
  local index = math.floor(i/2) + 1
  return autogft.CARDINAL_DIRECTIONS[index]
end

---
--This function might be computationally expensive
-- @param DCSUnit#Unit unit
-- @param #number radius
-- @return #autogft.UnitCluster
function autogft.getFriendlyVehiclesWithin(unit, radius)
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
    for i = 1, #list do
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
    addedVehiclesNames[#addedVehiclesNames + 1] = unit:getName()
  end

  ---
  -- @param DCSUnit#Unit unit
  local function vehiclesWithinRecurse(targetUnit)
    for i = 1, #units do
      local nextUnit = Unit.getByName(units[i])
      if nextUnit:getID() == targetUnit:getID() == false then
        if autogft.getDistanceBetween(targetUnit:getPosition().p, nextUnit:getPosition().p) <= radius then
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

  local result = autogft.UnitCluster:new()
  result.unitNames = addedVehiclesNames
  result.midPoint = midPoint
  return result

end

---
--Prints out a message to a group, describing nearest enemy vehicles
-- @param DCSGroup#Group group
function autogft.informOfClosestEnemyVehicles(group)

  local firstGroupUnit = group:getUnit(1)
  local closestEnemy = autogft.getClosestEnemyVehicle(firstGroupUnit:getName())
  local groupUnitPos = {
    x = firstGroupUnit:getPosition().p.x,
    y = 0,
    z = firstGroupUnit:getPosition().p.z
  }

  local enemyCluster = autogft.getFriendlyVehiclesWithin(closestEnemy, autogft.MAX_CLUSTER_DISTANCE)
  local midPoint = mist.utils.makeVec3(enemyCluster.midPoint)

  local dirRad = mist.utils.getDir(mist.vec.sub(midPoint, groupUnitPos))
  local dirDegree = math.floor(dirRad / math.pi * 18 + 0.5) * 10 -- Rounded to nearest 10
  --  local cardinalDir = autogft.radToCardinalDir(dirRad)
  local distance = autogft.getDistanceBetween(midPoint, groupUnitPos)
  local distanceKM = math.floor(distance / 1000 + 0.5)

  local vehicleTypes = {}
  for i = 1, #enemyCluster.unitNames do
    local type = Unit.getByName(enemyCluster.unitNames[i]):getTypeName()
    if vehicleTypes[type] == nil then
      vehicleTypes[type] = 0
    end

    vehicleTypes[type] = vehicleTypes[type] + 1
  end

  local text = ""
  for key, val in pairs(vehicleTypes) do
    if (text ~= "") then
      text = text..", "
    end
    text = text..val.." "..key
  end

  text = text .. " located " .. distanceKM .. "km at ~" .. dirDegree
  trigger.action.outTextForGroup(group:getID(), text, 30)

end

function autogft.enableIOCEV()

  local enabledGroupCommands = {}

  local function cleanEnabledGroupCommands()
    local newEnabledGroupCommands = {}
    for i = 1, #enabledGroupCommands do
      if not Group.getByName(enabledGroupCommands[i].groupName) then
        enabledGroupCommands[i]:disable()
      else
        newEnabledGroupCommands[#newEnabledGroupCommands + 1] = enabledGroupCommands[i]
      end
    end
    enabledGroupCommands = newEnabledGroupCommands
  end

  ---
  -- @param #number groupId
  local function groupHasCommandEnabled(groupId)
    for i = 1, #enabledGroupCommands do
      if enabledGroupCommands[i].groupId == groupId then
        return true
      end
    end
    return false
  end

  ---
  -- @param #list<DCSGroup#Group> groups
  local function enableForGroups(groups)
    for i = 1, #groups do
      local group = groups[i]
      if not groupHasCommandEnabled(group:getID()) then
        local function triggerCommand()
          autogft.informOfClosestEnemyVehicles(group)
        end
        local groupCommand = autogft.GroupCommand:new(autogft.IOCEV_COMMAND_TEXT, group:getName(), triggerCommand)
        groupCommand:enable()
        enabledGroupCommands[#enabledGroupCommands + 1] = groupCommand
      end
    end
  end

  local function reEnablingLoop()
    cleanEnabledGroupCommands()
    enableForGroups(coalition.getGroups(coalition.side.RED))
    enableForGroups(coalition.getGroups(coalition.side.BLUE))
    timer.scheduleFunction(reEnablingLoop, {}, timer.getTime() + 30)
  end

  reEnablingLoop()

end

---
-- Deep copy a table
--Code from https://gist.github.com/MihailJP/3931841
function autogft.deepCopy(t)
  if type(t) ~= "table" then return t end
  local meta = getmetatable(t)
  local target = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      target[k] = autogft.deepCopy(v)
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
function autogft.printIngame(str, time)
  if (time == nil) then
    time = 1
  end
  trigger.action.outText(str, time)
end

---
function autogft.debug(variable)
  autogft.printIngame(autogft.toString(variable))
end

---
-- Returns a string representation of an object
function autogft.toString(obj)

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

autogft.GROUP_COMMAND_FLAG_NAME = "groupCommandTrigger"
autogft.CARDINAL_DIRECTIONS = {"N", "N/NE", "NE", "NE/E", "E", "E/SE", "SE", "SE/S", "S", "S/SW", "SW", "SW/W", "W", "W/NW", "NW", "NW/N"}
autogft.MAX_CLUSTER_DISTANCE = 1000
autogft.IOCEV_COMMAND_TEXT = "Request location of enemy vehicles"
autogft.DEFAULT_AUTO_ISSUE_DELAY = 600
autogft.DEFAULT_AUTO_REINFORCE_DELAY = 1800

-- Counters
autogft.lastCreatedUnitId = 0
autogft.lastCreatedGroupId = 0
