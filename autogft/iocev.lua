---
-- @module IOCEV

autogft_CARDINAL_DIRECTIONS = {"N", "N/NE", "NE", "NE/E", "E", "E/SE", "SE", "SE/S", "S", "S/SW", "SW", "SW/W", "W", "W/NW", "NW", "NW/N"}
autogft_IOCEV_COMMAND_TEXT = "Request location of enemy vehicles"
autogft_MAX_CLUSTER_DISTANCE = 1000

---
-- @param #number rad Direction in radians
-- @return #string A string representing a cardinal direction
function autogft_radToCardinalDir(rad)

  local dirNormalized = rad / math.pi / 2
  local i = 1
  if dirNormalized < (#autogft_CARDINAL_DIRECTIONS-1) / #autogft_CARDINAL_DIRECTIONS then
    while dirNormalized > i/#autogft_CARDINAL_DIRECTIONS/2 do
      i = i + 2
    end
  end
  local index = math.floor(i/2) + 1
  return autogft_CARDINAL_DIRECTIONS[index]
end

---
-- Prints out a message to a group, describing nearest enemy vehicles
-- @param DCSGroup#Group group
function autogft_informOfClosestEnemyVehicles(group)

  local firstGroupUnit = group:getUnit(1)
  local closestEnemy = autogft_getClosestEnemyVehicle(firstGroupUnit:getName())
  if closestEnemy == nil then
    trigger.action.outTextForGroup(group:getID(), "No enemy vehicles", 30)
  else
    local groupUnitPos = {
      x = firstGroupUnit:getPosition().p.x,
      y = 0,
      z = firstGroupUnit:getPosition().p.z
    }

    local enemyCluster = autogft_getFriendlyVehiclesWithin(closestEnemy, autogft_MAX_CLUSTER_DISTANCE)
    local midPoint = mist.utils.makeVec3(enemyCluster.midPoint)

    local dirRad = mist.utils.getDir(mist.vec.sub(midPoint, groupUnitPos))
    local cardinalDir = autogft_radToCardinalDir(dirRad)
    local distanceM = autogft_getDistanceBetween(midPoint, groupUnitPos)
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
    text = text .. " located " .. distanceNMRounded .. "nm " .. cardinalDir .. " of group lead"
    trigger.action.outTextForGroup(group:getID(), text, 30)
  end

end

function autogft_enableIOCEV()

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
            autogft_informOfClosestEnemyVehicles(group)
          end
          local groupCommand = autogft_GroupCommand:new(autogft_IOCEV_COMMAND_TEXT, group:getName(), triggerCommand)
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
    autogft_scheduleFunction(reEnablingLoop, 30)
  end

  reEnablingLoop()

end

---
-- Locates friendly units within some range of each other.
-- This function might be computationally expensive.
-- @function getFriendlyVehiclesWithin
-- @param DCSUnit#Unit unit
-- @param #number radius
-- @return unitcluster#UnitCluster
function autogft_getFriendlyVehiclesWithin(unit, radius)
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
          if autogft_getDistanceBetween(targetUnit:getPosition().p, nextUnit:getPosition().p) <= radius then
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
-- @param #string unitName
-- @return DCSUnit#Unit
function autogft_getClosestEnemyVehicle(unitName)

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
          closestEnemyDistance = autogft_getDistanceBetween(unitPosition, closestEnemy:getPosition().p)
        else
          newClosestEnemyDistance = autogft_getDistanceBetween(unitPosition, newClosestEnemy:getPosition().p)
          if (newClosestEnemyDistance < closestEnemyDistance) then
            closestEnemy = newClosestEnemy
          end
        end
      end
    end
    return closestEnemy
  end
end
