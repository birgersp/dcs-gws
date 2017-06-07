---
-- @module InformedGroup

autogft_intel = {}
autogft_intel.RE_ENABLING_LOOP_DELAY = 10

autogft_intel.OBSERVABLE_DISTANCE_M = 6000
autogft_intel.COHERENT_UNIT_DISTANCE_M = 800
autogft_intel.INTEL_UPDATE_INTERVAL_S = 600
autogft_intel.intelMessage = {}
autogft_intel.intelMessage[coalition.side.RED] = ""
autogft_intel.intelMessage[coalition.side.BLUE] = ""

---
-- @param #list<DCSUnit#Unit> targetUnits
-- @param #number adjacentUnitThreshold
-- @return #list<unitcluster#UnitCluster>
function autogft_intel.getUnitClusters(targetUnits, adjacentUnitThreshold)

  local adjacentUnitThreshold2 = adjacentUnitThreshold^2

  ---
  -- Creates a cluster of units, from all units adjacent to an origin unit
  -- @param DCSUnit#Unit clusterOriginUnit
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
-- @param #list<DCSUnit#Unit> targetUnits
-- @param #number adjacentUnitThreshold
function autogft_intel.getTargetUnitsLLMessage(targetUnits, adjacentUnitThreshold)

  local clusters = autogft_intel.getUnitClusters(targetUnits, adjacentUnitThreshold)

  -- Create message from clusters
  local message = ""
  if #clusters == 0 then
    message = "(NO TARGETS)"
  else
    for clusterI = 1, #clusters do
      local cluster = clusters[clusterI] --unitcluster#UnitCluster

      local unitTypeCount = cluster:getUnitTypeCount()
      local text = ""
      for unitType, count in pairs(unitTypeCount) do
        if text ~= "" then
          text = text..", "
        end
        text = text..autogft_intel.getUnitCountTerm(count).." "
        text = text..autogft.getUnitTypeNameTerm(unitType)
      end

      local dcsVec3 = {
        x = cluster.midPoint.x,
        y = 0,
        z = cluster.midPoint.y
      }
      local lat, lon, _ = coord.LOtoLL(dcsVec3)
      local latCoordinate = autogft_Coordinate:new(lat)
      local lonCoordinate = autogft_Coordinate:new(lon)

      local latString = "N" .. latCoordinate:getDegreesString(2) .. " " .. latCoordinate:getMinutesString(1, 1) .. "00"
      local lonString = "E" .. lonCoordinate:getDegreesString(3) .. " " .. lonCoordinate:getMinutesString(1, 1) .. "00"

      text = text .. " at " .. latString .. ", " .. lonString
      message = message .. text .. "\n"
    end
  end
  return message
end

---
-- @type InformedGroup
-- @extends class#Class
-- @field DCSGroup#Group targetGroup
-- @field #number groupID
-- @field #number coalitionID
autogft_InformedGroup = autogft_Class:create()

autogft_InformedGroup.TARGET_COMMAND_TEXT = "TARGET"
autogft_InformedGroup.MESSAGE_TIME = 60
autogft_InformedGroup.NO_TARGETS_OBSERVED_MESSAGE = "No targets observed"

---
-- @param #InformedGroup self
-- @param DCSGroup#Group targetGroup
-- @return #InformedGroup
function autogft_InformedGroup:new(targetGroup)
  self = self:createInstance()
  self.targetGroup = targetGroup
  self.groupID = targetGroup:getID()
  self.coalitionID = targetGroup:getCoalition()

  local function viewTarget()
    self:viewTarget()
  end

  autogft_GroupCommand:new(targetGroup, autogft_InformedGroup.TARGET_COMMAND_TEXT, viewTarget):enable()

  return self
end

---
-- @param #InformedGroup self
function autogft_InformedGroup:viewTarget()

  trigger.action.outTextForGroup(self.groupID, autogft_intel.intelMessage[self.coalitionID], autogft_InformedGroup.MESSAGE_TIME)
end

---
-- @param #number count
-- @return #string
function autogft_intel.getUnitCountTerm(count)

  if count < 4 then
    return "Platoon"
  elseif count < 10 then
    return "Company"
  elseif count < 19 then
    return "2x Company"
  end

  return "Battalion"
end

function autogft_intel.getEnemySituationMessageHeader()

  local timeS = timer.getTime0() + timer.getAbsTime()
  local hour = math.floor(timeS / 3600)
  local minute = math.floor((timeS - (hour * 3600)) / 60)
  hour = hour + 12

  while hour >= 24 do
    hour = hour - 24
  end

  local hourString = "" .. hour
  while hourString:len() < 2 do
    hourString = "0" .. hourString
  end

  local minueString = "" .. minute
  while minueString:len() < 2 do
    minueString = "0" .. minueString
  end

  local message = "FROM: GROUND FORCE COMMANDER"
  message = message .. "\n" .. "TO: JTAC"
  message = message .. "\n"
  message = message .. "\n" .. "ENEMY SITUATION"
  message = message .. "\n" .. "As of " .. hourString .. ":" .. minueString .. "L We have received the following reporting:"

  return message

end

function autogft_intel.updateIntel()

  local observerMaxDistance2 = autogft_intel.OBSERVABLE_DISTANCE_M^2

  local observedRedUnits = {} --#list<DCSUnit#Unit>
  local observedBlueUnits = {} --#list<DCSUnit#Unit>

  local redGroups = coalition.getGroups(coalition.side.RED, Group.Category.GROUND)
  local blueGroups = coalition.getGroups(coalition.side.BLUE, Group.Category.GROUND)

  local observedRedUnitNames = {} --#list<#string>

  -- For each blue group
  for blueGroupI = 1, #blueGroups do
    local blueGroup = blueGroups[blueGroupI]
    if blueGroup and blueGroup:isExist() then
      local blueGroupUnits = blueGroup:getUnits()

      -- For each unit in blue group
      for blueUnitI = 1, #blueGroupUnits do
        local blueUnit = blueGroupUnits[blueUnitI] --DCSUnit#Unit
        if blueUnit and blueUnit:isExist() then

          local blueUnitObserved = false
          local observerPosition = blueUnit:getPosition().p

          -- For each red group
          for redGroupI = 1, #redGroups do
            local redGroup = redGroups[redGroupI]
            if redGroup and redGroup:isExist() then
              local redGroupUnits = redGroup:getUnits()

              -- For each unit in red group
              for redGroupI = 1, #redGroupUnits do
                local redUnit = redGroupUnits[redGroupI] --DCSUnit#Unit
                if redUnit and redUnit:isExist() then

                  local redUnitPos = redUnit:getPosition().p
                  local dX = redUnitPos.x - observerPosition.x
                  local dY = redUnitPos.y - observerPosition.y
                  local dZ = redUnitPos.z - observerPosition.z
                  local distance2 = dX*dX + dY*dY + dZ*dZ
                  if distance2 <= observerMaxDistance2 then
                    local redUnitName = redUnit:getName()
                    if not observedRedUnitNames[redUnitName] then
                      observedRedUnits[#observedRedUnits + 1] = redUnit
                      observedRedUnitNames[redUnit:getName()] = true
                    end
                    blueUnitObserved = true
                  end
                end
              end
            end
          end

          if blueUnitObserved then
            observedBlueUnits[#observedBlueUnits + 1] = blueUnit
          end
        end
      end
    end
  end

  local messageHeader = autogft_intel.getEnemySituationMessageHeader() .. "\n"
  autogft_intel.intelMessage[coalition.side.RED] = messageHeader .. autogft_intel.getTargetUnitsLLMessage(observedBlueUnits, autogft_intel.COHERENT_UNIT_DISTANCE_M)
  autogft_intel.intelMessage[coalition.side.BLUE] = messageHeader .. autogft_intel.getTargetUnitsLLMessage(observedRedUnits, autogft_intel.COHERENT_UNIT_DISTANCE_M)

end

---
-- @param #string groupNamePrefix
function autogft_intel.enable(groupNamePrefix)

  local function updateIntelLoop()
    autogft_intel.updateIntel()
    autogft.scheduleFunction(updateIntelLoop, autogft_intel.INTEL_UPDATE_INTERVAL_S)
  end
  updateIntelLoop()

  local enabledGroupNames = {}

  local function enableForGroups(groups)
    for groupI = 1, #groups do
      local group = groups[groupI]
      if group and group:isExist() and group:getName():find(groupNamePrefix) == 1 then
        local units = group:getUnits()
        for unitI = 1, #units do
          local unit = units[unitI] --DCSUnit#Unit
          if unit and unit:isExist() then
            if unit:getPlayerName() then
              local groupName = group:getName()
              if not enabledGroupNames[groupName] then
                autogft_InformedGroup:new(group)
                enabledGroupNames[groupName] = true
              end
            end
          end
        end
      end
    end
  end

  local function reEnablingLoop()

    enableForGroups(coalition.getGroups(coalition.side.BLUE))
    enableForGroups(coalition.getGroups(coalition.side.RED))

    autogft.scheduleFunction(reEnablingLoop, autogft_intel.RE_ENABLING_LOOP_DELAY)
  end
  reEnablingLoop()

end
