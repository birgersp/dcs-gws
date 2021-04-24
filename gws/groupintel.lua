---
-- @module GroupIntel

gws_groupIntel = {}

---
-- @type GroupIntel
-- @extends class#Class
-- @field DCSGroup#Group targetGroup
-- @field #number enemyCoalitionID
-- @field groupcommand#GroupCommand startCommand
-- @field groupcommand#GroupCommand stopCommand
-- @field #boolean started
gws_GroupIntel = gws_Class:create()

gws_GroupIntel.START_COMMAND_TEXT = "Activate intel"
gws_GroupIntel.STOP_COMMAND_TEXT = "Deactivate intel"
gws_GroupIntel.INTEL_LOOP_DELAY = 60
gws_GroupIntel.MESSAGE_TIME = 30
gws_GroupIntel.OBSERVABLE_DISTANCE_M = 18500

---
-- @param #GroupIntel self
-- @param DCSGroup#Group targetGroup
-- @return #GroupIntel
function gws_GroupIntel:new(targetGroup)

  self = self:createInstance()
  self.targetGroup = targetGroup
  self.enemyCoalitionID = gws.getEnemyCoalitionID(self.targetGroup:getUnits()[1])

  self.started = false

  local function start()
    self:start()
  end
  self.startCommand = gws_GroupCommand:new(targetGroup, gws_GroupIntel.START_COMMAND_TEXT, start)
  self.startCommand:enable()

  local function stop()
    self:stop()
  end
  self.stopCommand = gws_GroupCommand:new(targetGroup, gws_GroupIntel.STOP_COMMAND_TEXT, stop)

  return self
end

---
-- @param #GroupIntel self
function gws_GroupIntel:start()
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
        gws.scheduleFunction(intelLoop, gws_GroupIntel.INTEL_LOOP_DELAY)
      else
        self:stop()
      end
    end
  end
  intelLoop()
end

---
-- @param #GroupIntel self
function gws_GroupIntel:stop()
  self.started = false
  self.stopCommand:disable()
  self.startCommand:enable()
end

---
-- @param #GroupIntel self
function gws_GroupIntel:viewEnemyGroundTargets()

  local ownUnit = self.targetGroup:getUnit(1)
  local targetUnits = gws.getEnemyGroundUnitsWithin(ownUnit, gws_GroupIntel.OBSERVABLE_DISTANCE_M)
  local observerPosition = ownUnit:getPosition().p

  local message
  if (#targetUnits == 0) then
    message = gws_intel.NO_TARGETS_OBSERVED_MESSAGE
  else

    local observerPosVec2 = gws_Vector2:new(observerPosition.x, observerPosition.z)
    local observerHeadingNortCorrection = gws.getHeadingNorthCorrection(observerPosition)

    local clusters = gws_intel.getUnitClusters(targetUnits, gws_intel.COHERENT_UNIT_DISTANCE_M)

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
        text = text..count.." "..gws.getUnitTypeNameTerm(unitTypeName)
      end

      local observerToCluster = gws_Vector2.minus(cluster.midPoint, observerPosVec2)
      local dirRad = gws_Vector2.Axis.X:getAngleTo(observerToCluster) + observerHeadingNortCorrection
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

  trigger.action.outTextForGroup(self.targetGroup:getID(), message, gws_GroupIntel.MESSAGE_TIME)
end

function gws_groupIntel.enable()

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
                gws_GroupIntel:new(group)
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

    gws.scheduleFunction(reEnablingLoop, gws_intel.RE_ENABLING_LOOP_DELAY)
  end
  reEnablingLoop()

end
