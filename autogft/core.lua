-- Namespace declaration

autogft = {
  TaskForce = autogft_TaskForce
}

-- Constants

autogft.CARDINAL_DIRECTIONS = {"N", "N/NE", "NE", "NE/E", "E", "E/SE", "SE", "SE/S", "S", "S/SW", "SW", "SW/W", "W", "W/NW", "NW", "NW/N"}
autogft.MAX_CLUSTER_DISTANCE = 1000
autogft.IOCEV_COMMAND_TEXT = "Request location of enemy vehicles"
autogft.DEFAULT_AUTO_ISSUE_DELAY = 600
autogft.DEFAULT_AUTO_REINFORCE_DELAY = 1800

-- Misc

autogft.debugMode = false

-- Utility function definitions

---
-- @param DCSGroup#Group group
-- @param #string groupName
-- @param #string zoneName
function autogft.issueGroupTo(group, zoneName, speed, formation)
  local destinationZone = trigger.misc.getZone(zoneName)
  local destinationZonePos2 = {
    x = destinationZone.point.x,
    y = destinationZone.point.z
  }
  local randomPointVars = {
    group = group,
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
  local enemyCoalitionString = "[red]"
  if unit:getCoalition() == 1 then
    enemyCoalitionString = "[blue]"
  end
  local unitTableStr = enemyCoalitionString .. '[vehicle]'
  local enemyVehicles = mist.makeUnitTable({ unitTableStr })
  if #enemyVehicles > 0 then
    local closestEnemy
    local closestEnemyDistance
    local newClosestEnemy = {}
    local newClosestEnemyDistance = 0
    for i = 1, #enemyVehicles do
      newClosestEnemy = Unit.getByName(enemyVehicles[i])
      if newClosestEnemy ~= nil then
        if closestEnemy == nil then
          closestEnemy = newClosestEnemy
          closestEnemyDistance = autogft.getDistanceBetween(unitPosition, closestEnemy:getPosition().p)
        else
          newClosestEnemyDistance = autogft.getDistanceBetween(unitPosition, newClosestEnemy:getPosition().p)
          if (newClosestEnemyDistance < closestEnemyDistance) then
            closestEnemy = newClosestEnemy
          end
        end
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
-- This function might be computationally expensive
-- @param DCSUnit#Unit unit
-- @param #number radius
-- @return #autogft_UnitCluster
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
      if nextUnit then
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
  end

  vehiclesWithinRecurse(unit)

  local dx = maxPos.x - minPos.x
  local dz = maxPos.z - minPos.z

  local midPoint = { -- 3D to 2D conversion implemented
    x = minPos.x + dx / 2,
    y = minPos.z + dz / 2
  }

  local result = autogft_UnitCluster:new()
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
  if closestEnemy == nil then
    trigger.action.outTextForGroup(group:getID(), "No enemy vehicles", 30)
  else
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
    local distanceM = autogft.getDistanceBetween(midPoint, groupUnitPos)
    local distanceKM = distanceM / 1000
    local distanceNM = distanceKM / 1.852

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

    local distanceNMRounded = math.floor(distanceNM + 0.5)
    text = text .. " located " .. distanceNMRounded .. "nm at ~" .. dirDegree .. " from group lead"
    trigger.action.outTextForGroup(group:getID(), text, 30)
  end

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
  -- @param DCSGroup#Group group
  local function groupHasPlayer(group)
    local units = group:getUnits()
    for i = 1, #units do
      if units[i]:getPlayerName() ~= nil then return true end
    end
    return false
  end

  ---
  -- @param #list<DCSGroup#Group> groups
  local function enableForGroups(groups)
    for i = 1, #groups do
      local group = groups[i]
      if groupHasPlayer(group) then
        if not groupHasCommandEnabled(group:getID()) then
          local function triggerCommand()
            autogft.informOfClosestEnemyVehicles(group)
          end
          local groupCommand = autogft_GroupCommand:new(autogft.IOCEV_COMMAND_TEXT, group:getName(), triggerCommand)
          groupCommand:enable()
          enabledGroupCommands[#enabledGroupCommands + 1] = groupCommand
        end
      end
    end
  end

  local function reEnablingLoop()
    cleanEnabledGroupCommands()
    enableForGroups(coalition.getGroups(coalition.side.RED))
    enableForGroups(coalition.getGroups(coalition.side.BLUE))
    autogft.scheduleFunction(reEnablingLoop, 30)
  end

  reEnablingLoop()

end

function autogft.debug(variable, text)
  if autogft.debugMode then
    if text then
      env.info(text .. ": " .. autogft.toString(variable))
    else
      env.info(autogft.toString(variable))
    end
  end
end

---
-- @param #number coalitionId
-- @param #list<#string> zoneNames
function autogft.getUnitsInZones(coalitionId, zoneNames)
  local result = {}
  local groups = coalition.getGroups(coalitionId)
  for zoneNameIndex = 1, #zoneNames do
    local zone = trigger.misc.getZone(zoneNames[zoneNameIndex])
    local radiusSquared = zone.radius * zone.radius
    for groupIndex = 1, #groups do
      local units = groups[groupIndex]:getUnits()
      for unitIndex = 1, #units do
        local unit = units[unitIndex]
        local pos = unit:getPosition().p
        local dx = zone.point.x - pos.x
        local dy = zone.point.z - pos.z
        if (dx*dx + dy*dy) <= radiusSquared then
          result[#result + 1] = units[unitIndex]
        end
      end
    end
  end
  return result
end

---
-- @param #function func
-- @param #number time
function autogft.scheduleFunction(func, time)
  local function triggerFunction()
    local success, message = pcall(func)
    if not success then
      env.error("Error in scheduled function: "..message, true)
    end
  end
  timer.scheduleFunction(triggerFunction, {}, timer.getTime() + time)
end

---
-- Deep copy a table
-- Code from https://gist.github.com/MihailJP/3931841
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

---
-- @param #list list
-- @param # item
function autogft.contains(list, item)
  for i = 1, #list do
    if list[i] == item then return true end
  end
  return false
end

---
-- @param #string zoneName
function autogft.assertZoneExists(zoneName)
  assert(trigger.misc.getZone(zoneName) ~= nil, "Zone \""..zoneName.."\" does not exist in this mission.")
end
