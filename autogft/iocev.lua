---
-- @module IOCEV

autogft_iocev = {}

autogft_iocev.CARDINAL_DIRECTIONS = {"N", "N/NE", "NE", "NE/E", "E", "E/SE", "SE", "SE/S", "S", "S/SW", "SW", "SW/W", "W", "W/NW", "NW", "NW/N"}
autogft_iocev.COMMAND_TEXT = "Request location of enemy vehicles"
autogft_iocev.NO_VEHICLES_MSG = "No enemy vehicles in range"
autogft_iocev.MAX_CLUSTER_DISTANCE = 1000
autogft_iocev.MESSAGE_TIME = 30
autogft_iocev.COMMAND_ENABLING_DELAY = 5

---
-- @param #number rad Direction in radians
-- @return #string A string representing a cardinal direction
function autogft_iocev.radToCardinalDir(rad)

  local dirNormalized = rad / math.pi / 2
  local i = 1
  if dirNormalized < (#autogft_iocev.CARDINAL_DIRECTIONS-1) / #autogft_iocev.CARDINAL_DIRECTIONS then
    while dirNormalized > i / #autogft_iocev.CARDINAL_DIRECTIONS / 2 do
      i = i + 2
    end
  end
  local index = math.floor(i / 2) + 1
  return autogft_iocev.CARDINAL_DIRECTIONS[index]
end

---
-- Prints out a message to a group, describing nearest enemy vehicles
-- @param DCSGroup#Group group
function autogft_iocev.informOfClosestEnemyVehicles(group)

  local units = group:getUnits() --#list<DCSUnit#Unit>
  local unit = nil
  local unitIndex = 1
  while not unit and unitIndex <= #units do
    if units[unitIndex] and units[unitIndex]:isExist() then
      unit = units[unitIndex]
    else
      unitIndex = unitIndex + 1
    end
  end

  if not unit then
    do return end
  end

  local closestEnemy = autogft_iocev.getClosestEnemyGroundUnit(unit)

  if not closestEnemy then
    trigger.action.outTextForGroup(group:getID(), autogft_iocev.NO_VEHICLES_MSG, autogft_iocev.MESSAGE_TIME)
  else

    local enemyCluster = autogft_iocev.getFriendlyGroundUnitsWithin(closestEnemy, autogft_iocev.MAX_CLUSTER_DISTANCE)
    enemyCluster.units[#enemyCluster.units + 1] = closestEnemy

    local groupUnitPosDCS = unit:getPosition().p
    local groupUnitPos = autogft_Vector2:new(groupUnitPosDCS.x, groupUnitPosDCS.z)
    local groupToMid = autogft_Vector2.minus(enemyCluster.midPoint, groupUnitPos)

    local dirRad = autogft_Vector2.Axis.X:getAngleTo(groupToMid) + autogft.getHeadingNorthCorrection(groupUnitPosDCS)
    local cardinalDir = autogft_iocev.radToCardinalDir(dirRad)
    local distanceM = enemyCluster.midPoint:getCopy():scale(-1):add(groupUnitPos):getMagnitude()
    local distanceKM = distanceM / 1000
    local distanceNM = distanceKM / 1.852

    local unitTypes = {}
    for i = 1, #enemyCluster.units do
      local unit = enemyCluster.units[i]
      local typeName = unit:getTypeName()
      if unitTypes[typeName] == nil then
        unitTypes[typeName] = 0
      end
      unitTypes[typeName] = unitTypes[typeName] + 1
    end

    local text = ""
    for key, val in pairs(unitTypes) do
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

function autogft_iocev.enable()

  local enabledGroupCommands = {}

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
  -- @param DCSGroup#Group group
  local function enableForGroup(group)
    local function triggerCommand()
      local unit = group:getUnit(1)
      autogft_iocev.informOfClosestEnemyVehicles(group)
    end
    local groupCommand = autogft_GroupCommand:new(autogft_iocev.COMMAND_TEXT, group:getName(), triggerCommand)
    groupCommand:enable()
    enabledGroupCommands[group:getName()] = groupCommand
  end

  local function reEnablingLoop()

    local players = coalition.getPlayers(coalition.side.BLUE)
    for i = 1, #players do
      local player = players[i]
      local group = player:getGroup() --DCSGroup#Group
      local groupName = group:getName()
      if not enabledGroupCommands[groupName] then
        enableForGroup(group)
      end
    end

    autogft.scheduleFunction(reEnablingLoop, autogft_iocev.COMMAND_ENABLING_DELAY)
  end

  reEnablingLoop()

end

---
-- Locates friendly units within some range of each other.
-- This function might be computationally expensive.
-- @param DCSUnit#Unit unit
-- @param #number radius
-- @return unitcluster#UnitCluster
function autogft_iocev.getFriendlyGroundUnitsWithin(unit, radius)

  local unitsWithinRange = {} --#list<DCSUnit#Unit>
  local unitsWithinRangeNames = {}

  local minPos = unit:getPosition().p
  local maxPos = unit:getPosition().p

  -- Build table of all friendly ground units
  local friendlyGroundUnits = {} --#list<DCSUnit#Unit>
  autogft_iocev.forEachCoalitionUnit(unit:getCoalition(), function(friendlyUnit) friendlyGroundUnits[#friendlyGroundUnits + 1] = friendlyUnit end, Group.Category.GROUND)

  local radius2 = radius^2

  ---
  -- @param DCSUnit#Unit unit
  local function addUnit(unit)
    local pos = unit:getPosition().p
    if pos.x < minPos.x then minPos.x = pos.x end
    if pos.z < minPos.z then minPos.z = pos.z end
    if pos.x > maxPos.x then maxPos.x = pos.x end
    if pos.z > maxPos.z then maxPos.z = pos.z end
    unitsWithinRange[#unitsWithinRange + 1] = unit
    unitsWithinRangeNames[unit:getName()] = true
  end

  ---
  -- @param DCSUnit#Unit unit
  local function vehiclesWithinRecurse(targetUnit)

    local targetUnitPos = targetUnit:getPosition().p

    for i = 1, #friendlyGroundUnits do
      local friendlyGroundUnit = friendlyGroundUnits[i] --DCSUnit#Unit
      local friendlyGroundUnitID = friendlyGroundUnit:getID()
      if friendlyGroundUnitID ~= unit:getID() and friendlyGroundUnitID ~= targetUnit:getID() then

        local unitPos = friendlyGroundUnit:getPosition().p
        local dX = unitPos.x - targetUnitPos.x
        local dY = unitPos.y - targetUnitPos.y
        local dZ = unitPos.z - targetUnitPos.z
        local distance2 = dX*dX + dY*dY + dZ*dZ

        if distance2 <= radius2 and not unitsWithinRangeNames[friendlyGroundUnit:getName()] then
          addUnit(friendlyGroundUnit)
          vehiclesWithinRecurse(friendlyGroundUnit)
        end
      end
    end
  end

  vehiclesWithinRecurse(unit)

  local dx = maxPos.x - minPos.x
  local dz = maxPos.z - minPos.z

  local midPoint = autogft_Vector2:new(minPos.x + dx / 2, minPos.z + dz / 2)

  local result = autogft_UnitCluster:new(unitsWithinRange, midPoint)
  return result
end

---
-- @param DCSUnit#Unit unit
-- @return DCSUnit#Unit
function autogft_iocev.getClosestEnemyGroundUnit(unit)

  local unitPosition = unit:getPosition().p

  local enemyCoalitionID
  if unit:getCoalition() == coalition.side.BLUE then
    enemyCoalitionID = coalition.side.RED
  else
    enemyCoalitionID = coalition.side.BLUE
  end

  local closestEnemy
  local closestEnemyDistance2

  -- For each enemy group
  autogft_iocev.forEachCoalitionUnit(enemyCoalitionID,
    function(enemyUnit)
      -- Determine distance (squared) between unit and enemy
      local ePos = enemyUnit:getPosition().p
      local dX = ePos.x - unitPosition.x
      local dY = ePos.y - unitPosition.y
      local dZ = ePos.z - unitPosition.z
      local distance2 = dX*dX + dY*dY + dZ*dZ

      if (not closestEnemy) or distance2 < closestEnemyDistance2 then
        closestEnemy = enemyUnit
        closestEnemyDistance2 = distance2
      end
    end, Group.Category.GROUND)

  return closestEnemy
end

---
-- @param #number coalitionID
-- @param #function func
-- @param #number category
function autogft_iocev.forEachCoalitionUnit(coalitionID, func, category)

  local groups = coalition.getGroups(coalitionID, category)
  for groupIndex = 1, #groups do
    local group = groups[groupIndex] --DCSGroup#Group
    if group:isExist() then

      local groupUnits = group:getUnits()
      for groupUnitIndex = 1, #groupUnits do
        local unit = groupUnits[groupUnitIndex]
        if unit:isExist() then
          func(unit)
        end
      end
    end
  end
end
