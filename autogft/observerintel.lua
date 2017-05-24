---
-- @module ObserverIntel

autogft_observerIntel = {}
autogft_observerIntel.RE_ENABLING_LOOP_DELAY = 10

---
-- @param #list<DCSUnit#Unit> targetUnits
-- @param #number adjacentUnitThreshold
function autogft_observerIntel.getUnitClusters(targetUnits, adjacentUnitThreshold)

  local adjacentUnitThreshold2 = adjacentUnitThreshold^2

  ---
  -- Creates a cluster of units, from all units adjacent to an origin unit
  local function getCluster(clusterOriginUnit)

    local unitsWithinRange = {} --#list<DCSUnit#Unit>
    local unitsWithinRangeIndices = {}
    local unitsWithinRangeNames = {}

    local minPos = clusterOriginUnit:getPosition().p
    local maxPos = clusterOriginUnit:getPosition().p

    ---
    -- Adds a unit to the cluster
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
    -- Iterates through units to see if they are adjacent to a target unit
    -- @param DCSUnit#Unit unit
    local function vehiclesWithinRecurse(targetUnit)
      local targetUnitPos = targetUnit:getPosition().p
      for i = 1, #targetUnits do
        local friendlyGroundUnit = targetUnits[i] --DCSUnit#Unit

        -- If not previously added
        if not unitsWithinRangeNames[friendlyGroundUnit:getName()] then

          -- If unit is target unit (self)
          if friendlyGroundUnit:getName() == targetUnit:getName() then
            addUnit(friendlyGroundUnit)
          else
            -- Verify that friendly unit is within range of target unit
            local unitPos = friendlyGroundUnit:getPosition().p
            local dX = unitPos.x - targetUnitPos.x
            local dY = unitPos.y - targetUnitPos.y
            local dZ = unitPos.z - targetUnitPos.z
            local distance2 = dX*dX + dY*dY + dZ*dZ
            if distance2 <= adjacentUnitThreshold2 then
              addUnit(friendlyGroundUnit)
              vehiclesWithinRecurse(friendlyGroundUnit)
            end
          end
        end
      end
    end
    vehiclesWithinRecurse(clusterOriginUnit)

    -- Units put into the cluster are removed from the list of available enemy units
    local newAvailableUnits = {}
    for i = 1, #targetUnits do
      if not unitsWithinRangeNames[targetUnits[i]:getName()] then
        newAvailableUnits[#newAvailableUnits + 1] = targetUnits[i]
      end
    end
    targetUnits = newAvailableUnits

    -- Determine cluster midpoint
    local dx = maxPos.x - minPos.x
    local dz = maxPos.z - minPos.z
    local midPoint = autogft_Vector2:new(minPos.x + dx / 2, minPos.z + dz / 2)

    return autogft_UnitCluster:new(unitsWithinRange, midPoint)
  end

  -- Create clusters from all available enemy units
  local clusters = {}
  while #targetUnits > 0 do
    local cluster = getCluster(targetUnits[1])
    clusters[#clusters + 1] = cluster
  end

  return clusters
end

---
-- @param DCSVec3#Vec3 observerPosition
-- @param #list<DCSUnit#Unit> targetUnits
-- @param #number adjacentUnitThreshold
function autogft_observerIntel.getTargetUnitsLLMessage(observerPosition, targetUnits, adjacentUnitThreshold)

  local observerPosVec2 = autogft_Vector2:new(observerPosition.x, observerPosition.z)
  local observerHeadingNortCorrection = autogft.getHeadingNorthCorrection(observerPosition)

  local clusters = autogft_observerIntel.getUnitClusters(targetUnits, adjacentUnitThreshold)

  -- Create message from clusters
  local message = ""
  for clusterI = 1, #clusters do
    local cluster = clusters[clusterI] --unitcluster#UnitCluster
    local unitTypes = {}
    for i = 1, #cluster.units do
      local unit = cluster.units[i]
      local typeName = unit:getTypeName()
      if unitTypes[typeName] == nil then
        unitTypes[typeName] = 0
      end
      unitTypes[typeName] = unitTypes[typeName] + 1
    end

    local text = ""
    for key, val in pairs(unitTypes) do
      if text ~= "" then
        text = text..", "
      end
      text = text..val.." "..key
      autogft.log(text)
    end

    local dcsVec3 = {
      x = cluster.midPoint.x,
      y = 0,
      z = cluster.midPoint.y
    }
    local lat, lon, _ = coord.LOtoLL(dcsVec3)

    --    local observerToCluster = autogft_Vector2.minus(cluster.midPoint, observerPosVec2)
    --    local dirRad = autogft_Vector2.Axis.X:getAngleTo(observerToCluster) + observerHeadingNortCorrection
    --    local dirHeading = math.floor(dirRad / math.pi * 180 + 0.5)
    --    local distanceM = observerToCluster:getMagnitude()
    --    local distanceKM = distanceM / 1000
    --    local distanceNM = distanceKM / 1.852
    --    local distanceNMRounded = math.floor(distanceNM + 0.5)

    text = text .. " at " .. lat .. ", " .. lon
    message = message .. text .. "\n"
  end
  return message
end

---
-- @type ObserverIntel
-- @extends class#Class
-- @field DCSGroup#Group targetGroup
-- @field #number groupID
-- @field #number enemyCoalitionID
autogft_ObserverIntel = autogft_Class:create()

autogft_ObserverIntel.TARGET_COMMAND_TEXT = "TARGET"
autogft_ObserverIntel.OBSERVER_MAX_DISTANCE_M = 18500
autogft_ObserverIntel.UNIT_GROUP_MAX_DISTANCE_M = 800
autogft_ObserverIntel.MESSAGE_TIME = 60
autogft_ObserverIntel.NO_TARGETS_OBSERVED_MESSAGE = "No targets observed"

---
-- @param #ObserverIntel self
-- @param DCSGroup#Group targetGroup
-- @return #ObserverIntel
function autogft_ObserverIntel:new(targetGroup)
  self = self:createInstance()
  self.targetGroup = targetGroup
  self.groupID = targetGroup:getID()

  self.enemyCoalitionID = coalition.side.RED
  if self.targetGroup:getCoalition() == coalition.side.RED then
    self.enemyCoalitionID = coalition.side.BLUE
  end

  local function viewTarget()
    self:viewTarget()
  end

  autogft_GroupCommand:new(targetGroup, autogft_ObserverIntel.TARGET_COMMAND_TEXT, viewTarget):enable()

  return self
end

---
-- @param #ObserverIntel self
function autogft_ObserverIntel:viewTarget()

  local enemyGroundGroups = coalition.getGroups(self.enemyCoalitionID)
  local observerMaxDistance2 = self.OBSERVER_MAX_DISTANCE_M^2

  local observerPosition = self.targetGroup:getUnit(1):getPosition().p

  local unitGroupMaxDistance2 = autogft_ObserverIntel.UNIT_GROUP_MAX_DISTANCE_M^2

  -- Create list of enemy units within max distance
  local availableEnemyUnits = {}
  for enemyGroupI = 1, #enemyGroundGroups do
    local enemyGroup = enemyGroundGroups[enemyGroupI]
    if enemyGroup and enemyGroup:isExist() then
      local enemyUnits = enemyGroup:getUnits()
      for enemyUnitI = 1, #enemyUnits do
        local enemyUnit = enemyUnits[enemyUnitI] --DCSUnit#Unit
        if enemyUnit and enemyUnit:isExist() then
          local enemyPos = enemyUnit:getPosition().p
          local dX = enemyPos.x - observerPosition.x
          local dY = enemyPos.y - observerPosition.y
          local dZ = enemyPos.z - observerPosition.z
          local distance2 = dX*dX + dY*dY + dZ*dZ
          if distance2 <= observerMaxDistance2 then
            availableEnemyUnits[#availableEnemyUnits + 1] = enemyUnit
          end
        end
      end
    end
  end

  local message
  if (#availableEnemyUnits == 0) then
    message = autogft_ObserverIntel.NO_TARGETS_OBSERVED_MESSAGE
  else
    message = autogft_observerIntel.getTargetUnitsLLMessage(observerPosition, availableEnemyUnits, autogft_ObserverIntel.UNIT_GROUP_MAX_DISTANCE_M)
  end

  trigger.action.outTextForGroup(self.groupID, message, autogft_ObserverIntel.MESSAGE_TIME)
end

---
-- @param #string groupNamePrefix
function autogft_observerIntel.enable(groupNamePrefix)

  local enabledGroupNames = {}

  ---
  -- @param #list<DCSUnit#Unit> players
  local function enableForPlayers(players)

    for i = 1, #players do
      local player = players[i]
      local group = player:getGroup()
      local groupName = group:getName()
      if not enabledGroupNames[groupName] and groupName:find(groupNamePrefix) == 1 then
        autogft_ObserverIntel:new(group)
        enabledGroupNames[groupName] = true
      end
    end
  end

  local function reEnablingLoop()

    enableForPlayers(coalition.getPlayers(coalition.side.BLUE))
    enableForPlayers(coalition.getPlayers(coalition.side.RED))

    autogft.scheduleFunction(reEnablingLoop, autogft_observerIntel.RE_ENABLING_LOOP_DELAY)
  end
  reEnablingLoop()

end
