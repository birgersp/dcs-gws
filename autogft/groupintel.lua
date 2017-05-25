---
-- @module GroupIntel

autogft_groupIntel = {}

---
-- @type GroupIntel
-- @extends class#Class
-- @field DCSGroup#Group targetGroup
-- @field #number enemyCoalitionID
-- @field groupcommand#GroupCommand startCommand
-- @field groupcommand#GroupCommand stopCommand
-- @field #boolean started
autogft_GroupIntel = autogft_Class:create()

autogft_GroupIntel.START_COMMAND_TEXT = "START INTEL"
autogft_GroupIntel.STOP_COMMAND_TEXT = "STOP INTEL"
autogft_GroupIntel.INTEL_LOOP_DELAY = 60
autogft_GroupIntel.MESSAGE_TIME = 30

---
-- @param #GroupIntel self
-- @param DCSGroup#Group targetGroup
-- @return #GroupIntel
function autogft_GroupIntel:new(targetGroup)

  self = self:createInstance()
  self.targetGroup = targetGroup
  self.enemyCoalitionID = autogft.getEnemyCoalitionID(self.targetGroup:getUnits()[1])

  self.started = false

  local function start()
    self:start()
  end
  self.startCommand = autogft_GroupCommand:new(targetGroup, autogft_GroupIntel.START_COMMAND_TEXT, start)
  self.startCommand:enable()

  local function stop()
    self:stop()
  end
  self.stopCommand = autogft_GroupCommand:new(targetGroup, autogft_GroupIntel.STOP_COMMAND_TEXT, stop)

  return self
end

---
-- @param #GroupIntel self
function autogft_GroupIntel:start()
  if self.started then
    do return end
  end

  self.started = true
  self.startCommand:disable()
  self.stopCommand:enable()

  local function intelLoop()
    if self.started then
      if self.targetGroup:isExist() then
        self:viewEnemyGroundTargets()
        autogft.scheduleFunction(intelLoop, autogft_GroupIntel.INTEL_LOOP_DELAY)
      else
        self:stop()
      end
    end
  end
  intelLoop()
end

---
-- @param #GroupIntel self
function autogft_GroupIntel:stop()
  self.started = false
  self.stopCommand:disable()
  self.startCommand:enable()
end

---
-- @param #GroupIntel self
function autogft_GroupIntel:viewEnemyGroundTargets()

  local ownUnit = self.targetGroup:getUnit(1)
  local targetUnits = autogft.getEnemyGroundUnitsWithin(ownUnit, autogft_ObserverIntel.OBSERVER_MAX_DISTANCE_M)
  local observerPosition = ownUnit:getPosition().p

  local message
  if (#targetUnits == 0) then
    message = autogft_ObserverIntel.NO_TARGETS_OBSERVED_MESSAGE
  else

    local observerPosVec2 = autogft_Vector2:new(observerPosition.x, observerPosition.z)
    local observerHeadingNortCorrection = autogft.getHeadingNorthCorrection(observerPosition)

    local clusters = autogft_observerIntel.getUnitClusters(targetUnits, autogft_ObserverIntel.UNIT_GROUP_MAX_DISTANCE_M)

    -- Create message from clusters
    message = ""
    for clusterI = 1, #clusters do
      local cluster = clusters[clusterI] --unitcluster#UnitCluster
      local unitTypeCount = cluster:getUnitTypeCount()
      local text = ""
      for unitTypeName, count in pairs(unitTypeCount) do
        if text ~= "" then
          text = text..", "
        end
        text = text..count.." "..autogft.getUnitTypeNameTerm(unitTypeName)
      end

      local observerToCluster = autogft_Vector2.minus(cluster.midPoint, observerPosVec2)
      local dirRad = autogft_Vector2.Axis.X:getAngleTo(observerToCluster) + observerHeadingNortCorrection
      local dirHeading = math.floor(dirRad / math.pi * 180 + 0.5)
      local distanceM = observerToCluster:getMagnitude()
      local distanceKM = distanceM / 1000
      local distanceNM = distanceKM / 1.852
      local distanceNMRounded = math.floor(distanceNM + 0.5)
      local distanceKMFloored = math.floor(distanceKM)

      text = text .. ", " .. distanceKMFloored .. "km at " .. dirHeading
      message = message .. text .. "\n"
    end
  end

  trigger.action.outTextForGroup(self.targetGroup:getID(), message, autogft_GroupIntel.MESSAGE_TIME)
end

function autogft_groupIntel.enable()

  local enabledGroupNames = {}

  local function enableForGroups(groups)
    for groupI = 1, #groups do
      local group = groups[groupI]
      if group and group:isExist() then
        local units = group:getUnits()
        for unitI = 1, #units do
          local unit = units[unitI] --DCSUnit#Unit
          if unit and unit:isExist() then
            if unit:getPlayerName() then
              local groupName = group:getName()
              if not enabledGroupNames[groupName] then
                autogft_GroupIntel:new(group)
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

    autogft.scheduleFunction(reEnablingLoop, autogft_observerIntel.RE_ENABLING_LOOP_DELAY)
  end
  reEnablingLoop()

end
