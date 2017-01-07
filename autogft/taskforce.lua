---
-- AI units which can be set to automatically capture target zones, advance through captured zones and be reinforced when taking casualties.
-- @module taskforce

---
-- @type autogft_TaskForce
-- @field #number country Country ID
-- @field #list<#string> baseZones List of base zones
-- @field #list<controlzone#autogft_ControlZone> targetZones List of target zones
-- @field #number speed Desired speed of moving units, in knots (default: max speed)
-- @field #number maxDistanceKM Maximum distance of task force routes between each advancement, in kilometres (default: 10)
-- @field #string formation Formation of moving units (default: "cone")
-- @field #boolean useRoads Wether the task force should use roads or not (default: false)
-- @field #string skill Skill of units (default: "High")
-- @field #list<taskforcegroup#autogft_TaskForceGroup> groups Groups of the task force
-- @field #string target Name of the zone that this task force is currently targeting
-- @field #boolean keepReinforcing Declares wheter this task force should keep reinforcing (if timers are set) or not (default: true)
autogft_TaskForce = {}

---
-- Creates a new task force instance.
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:new()
  self = setmetatable({}, {__index = autogft_TaskForce})
  self.country = -1
  self.baseZones = {}
  self.targetZones = {}
  self.speed = 100
  self.maxDistanceKM = 10
  self.formation = "cone"
  self.useRoads = false
  self.skill = "High"
  self.groups = {}
  self.target = ""
  self.keepReinforcing = true
  return self
end

---
-- Adds a group specification.
-- Group specifications what kind of units the task force shall consist of.
-- See "unit-types" for a complete list of available unit types.
-- @param #autogft_TaskForce self
-- @param #number count Number of units for the group
-- @param #string type Type of unit
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:addGroup(count, type)
  local unitSpec = autogft_UnitSpec:new(count, type)
  self.groups[#self.groups + 1] = autogft_TaskForceGroup:new(unitSpec)
  return self
end

---
-- Triggers task force reinforcing (invokes @{#autogft_TaskForce.reinforceFromUnits}) by either looking up units in base zones or spawning new units.
-- @param #autogft_TaskForce self
-- @param #boolean useSpawning (Optional) Specifies wether to spawn new units or use pre-existing units (default is false, using units located in base)
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:reinforce(useSpawning)
  self:assertValid()
  local availableUnits
  if not useSpawning then
    availableUnits = autogft_getUnitsInZones(coalition.getCountryCoalition(self.country), self.baseZones)
  end
  return self:reinforceFromUnits(availableUnits)
end

---
-- Checks the status of target zones, and sets the current target zone (@{#autogft_TaskForce.target}) of this task force.
-- This function iterates through the target zones, updating the status of each.
-- If no enemies are present, and friendly units are present, the zone is considered "cleared".
-- If enemies are present, the zone is considered "uncleared".
-- If no units are present in the zone, its state is left unchanged.
-- Once a zone is considered "uncleared", this is set as the task force's current target.
-- If all zones are considered "cleared", the last target zone added will be set as the current target.
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce This object (self)
function autogft_TaskForce:updateTarget()
  local redVehicles = mist.makeUnitTable({'[red][vehicle]'})
  local blueVehicles = mist.makeUnitTable({'[blue][vehicle]'})

  local done = false
  local zoneIndex = 1
  while done == false and zoneIndex <= #self.targetZones do
    local zone = self.targetZones[zoneIndex]
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
    self.target = self.targetZones[#self.targetZones].name
  end
  return self
end

---
-- Sets all units to move (directly) towards the current target.
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:moveToTarget()
  for i = 1, #self.groups do
    if self.groups[i]:exists() then self:moveGroupToTarget(self.groups[i].dcsGroup) end
  end
  return self
end

---
-- Starts a timer which updates the current target zone, and issues the task force units to engage it on given time intervals.
-- Invokes @{#autogft_TaskForce.moveToTarget}.
-- @param #autogft_TaskForce self
-- @param #number timeInterval Seconds between each target update
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:setAdvancementTimer(timeInterval)
  self:assertValid()
  local function autoIssue()
    self:updateTarget()
    self:moveToTarget()
    autogft_scheduleFunction(autoIssue, timeInterval)
  end
  autogft_scheduleFunction(autoIssue, timeInterval)
  return self
end

---
-- Starts a timer which reinforces the task force.
-- @param #autogft_TaskForce self
-- @param #number timeInterval Seconds between each reinforcement
-- @param #number maxTime (Optional) Maximum time the timer will run for
-- @param #boolean useSpawning (Optional) Specifies wether to spawn new units or use pre-existing units (default)
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:setReinforceTimer(timeInterval, maxTime, useSpawning)
  self:assertValid()

  self.keepReinforcing = true

  local function reinforce()
    if self.keepReinforcing then
      self:reinforce(useSpawning)
      autogft_scheduleFunction(reinforce, timeInterval)
    end
  end

  autogft_scheduleFunction(reinforce, timeInterval)

  if maxTime ~= nil and maxTime > 0 then
    local function killTimer()
      self.keepReinforcing = false
    end
    autogft_scheduleFunction(killTimer, maxTime)
  end
  return self
end

---
-- Enables a advancement timer (at 10 min intervals) and a respawning timer (at 30 min intervals).
-- See @{#autogft_TaskForce.setAdvancementTimer} and @{#autogft_TaskForce.enableRespawnTimer}
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:enableDefaultTimers()
  self:setAdvancementTimer(600)
  self:enableRespawnTimer(1800)
  return self
end

---
-- Checks if a particular unit is present in this task force.
-- @param #autogft_TaskForce self
-- @param DCSUnit#Unit unit Unit in question
-- @return #boolean True if this task force contains the unit, false otherwise.
function autogft_TaskForce:containsUnit(unit)
  for groupIndex = 1, #self.groups do
    if self.groups[groupIndex]:containsUnit(unit) then return true end
  end
  return false
end

---
-- Reinforce the task force by spawning new units.
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:respawn()
  return self:reinforce(true)
end

---
-- Starts a timer which reinforces the task force by spawning new units.
-- @param #autogft_TaskForce self
-- @param #number timeInterval Seconds between each reinforcement
-- @param #number maxTime (Optional) Maximum time the timer will run for
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:setRespawnTimer(timeInterval, maxTime)
  return self:setReinforceTimer(timeInterval, maxTime, true)
end

---
-- Sets the country ID of this task force.
-- @param #autogft_TaskForce self
-- @param #number country Country ID
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:setCountry(country)
  self.country = country
  return self
end

---
-- Adds a base zone to the task force, used for reinforcing (spawning or staging area).
-- @param #autogft_TaskForce self
-- @param #string baseZone Name of base zone
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:addBaseZone(baseZone)
  autogft_assertZoneExists(baseZone)
  self.baseZones[#self.baseZones + 1] = baseZone
  return self
end

---
-- Adds a target control zone to the task force. The goal of the task force will be to clear this zone of enemy units.
-- @param #autogft_TaskForce self
-- @param #string name Name of target control zone
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:addControlZone(name)
  autogft_assertZoneExists(name)
  local targetControlZone = autogft_ControlZone:new(name)
  self.targetZones[#self.targetZones + 1] = targetControlZone
  if #self.targetZones == 1 then self.target = name end
  return self
end

---
-- Asserts that country, base zones, target zones and unit specifications are set.
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:assertValid()
  assert(self.country ~= -1, "Task force country is missing. Use \"setCountry\" to set a country.")
  assert(#self.baseZones > 0, "Task force has no base zones. Use \"addBaseZone\" to add a base zone.")
  assert(#self.targetZones > 0, "Task force has no target zones. Use \"addControlZone\" to add a target zone.")
  assert(#self.groups > 0, "Task force as no group specifications. Use \"addGroup\" to add a unit specification.")
  return self
end

---
-- Sets the skill of the task force reinforcement units.
-- @param #autogft_TaskForce self
-- @param #string skill New skill
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:setSkill(skill)
  self.skill = skill
  return self
end

---
-- Issues a group to move to a random point within a zone.
-- @param #autogft_TaskForce self
-- @param DCSGroup#Group group Group instance to move
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:moveGroupToTarget(group)

  local destinationZone = trigger.misc.getZone(self.target)
  local destinationZonePos2 = {
    x = destinationZone.point.x,
    y = destinationZone.point.z
  }
  local radius = destinationZone.radius

  -- If the task force has a "max distance" specified
  if self.maxDistanceKM > 0 then
    local units = group:getUnits()
    local unitIndex = 1
    local groupLeader
    while not groupLeader and unitIndex <= #units do
      if units[unitIndex]:isExist() then
        groupLeader = units[unitIndex]
      else
        unitIndex = unitIndex + 1
      end
    end
    if not groupLeader then return self end
    local groupPos = groupLeader:getPosition().p
    local groupToZone = {
      x = destinationZone.point.x - groupPos.x,
      z = destinationZone.point.z - groupPos.z
    }
    local groupToZoneMag = math.sqrt(groupToZone.x^2 + groupToZone.z^2)
    local maxDistanceM = self.maxDistanceKM * 1000
    if groupToZoneMag - destinationZone.radius > maxDistanceM then
      destinationZonePos2.x = groupPos.x + groupToZone.x / groupToZoneMag * maxDistanceM
      destinationZonePos2.y = groupPos.z + groupToZone.z / groupToZoneMag * maxDistanceM
      radius = 0
    end
  end

  local randomPointVars = {
    group = group,
    point = destinationZonePos2,
    radius = radius,
    speed = self.speed,
    formation = self.formation,
    disableRoads = not self.useRoads
  }
  mist.groupToRandomPoint(randomPointVars)

  return self
end

---
-- Sets the maximum distance of unit routes (see @{#autogft_TaskForce.maxDistanceKM}).
-- If set, this number constrains how far groups of the task force will move between each move command (advancement).
-- When units are moving towards a target, units will stop at this distance and wait for the next movement command.
-- This prevents lag when computing routes over long distances.
-- @param #autogft_TaskForce self
-- @param #number maxDistanceKM Maximum distance (kilometres)
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:setMaxRouteDistance(maxDistanceKM)
  self.maxDistanceKM = maxDistanceKM
  return self
end

---
-- Sets wether the task force should use roads or not (see @{#autogft_TaskForce.useRoads}).
-- @param #autogft_TaskForce self
-- @param #boolean useRoads (Optional) Wether to use roads or not (default: true)
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:setUseRoads(useRoads)
  if useRoads == nil then
    self.useRoads = true
  else
    self.useRoads = useRoads
  end
  return self
end

---
-- Sets the desired speed of the task force units when advancing (see @{#autogft_TaskForce.speed}).
-- @param #autogft_TaskForce self
-- @param #boolean speed New speed (in knots)
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:setSpeed(speed)
  self.speed = speed
  return self
end

---
-- Attempts to reinforce the task force according to its unit specifications using a list of available units.
-- Reinforced units will immidiately start moving towards current target zone (see @{#autogft_TaskForce.target}).
-- @param #autogft_TaskForce self
-- @param #list<DCSUnit#Unit> availableUnits (Optional) Available units (if this list is not specified, units will be spawned)
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:reinforceFromUnits(availableUnits)

  local finished = false
  local spawnedUnitCount, takenUnits, replacedUnitNameCounter

  if availableUnits then
    -- Cancel if the list of available units have a length of 0
    if #availableUnits <= 0 then finished = true else takenUnits = {} end
  else
    spawnedUnitCount = 0
    replacedUnitNameCounter = 0
  end

  local replacedGroupNameCounter = 0

  -- Iterate through task force groups
  local groupIndex = 1
  while groupIndex <= #self.groups and not finished do

    local group = self.groups[groupIndex]
    if not group:exists() then

      local unitSpec = group.unitSpec

      local groupUnits = {}
      local function addUnit(type, name, x, y, heading)
        groupUnits[#groupUnits + 1] = {
          ["type"] = type,
          ["transportable"] =
          {
            ["randomTransportable"] = false,
          },
          ["x"] = x,
          ["y"] = y,
          ["heading"] = heading,
          ["name"] = name,
          ["skill"] = self.skill,
          ["playerCanDrive"] = true
        }
      end

      if availableUnits then
        -- Use pre-existing units
        local availableUnitIndex = 1
        while #groupUnits < unitSpec.count and availableUnitIndex <= #availableUnits do
          local unit = availableUnits[availableUnitIndex]
          if unit:isExist()
            and not takenUnits[availableUnitIndex]
            and unit:getTypeName() == unitSpec.type then
            local x = unit:getPosition().p.x
            local y = unit:getPosition().p.z
            local heading = mist.getHeading(unit)
            addUnit(unitSpec.type, unit:getName(), x, y, heading)
            takenUnits[availableUnitIndex] = true
          end
          availableUnitIndex = availableUnitIndex + 1
        end
        if #takenUnits >= #availableUnits then finished = true end
      else
        -- Spawn new units
        local spawnZoneIndex = math.random(#self.baseZones)
        local spawnZone = trigger.misc.getZone(self.baseZones[spawnZoneIndex])

        while #groupUnits < unitSpec.count do
          local name
          -- Find a unique unit name
          while (not name) or Unit.getByName(name) do
            replacedUnitNameCounter = replacedUnitNameCounter + 1
            name = "autogft unit #" .. replacedUnitNameCounter
          end
          local x = spawnZone.point.x + 15 * spawnedUnitCount
          local y = spawnZone.point.z - 15 * spawnedUnitCount
          addUnit(unitSpec.type, name, x, y, 0)
          spawnedUnitCount = spawnedUnitCount + 1
        end
      end

      if #groupUnits > 0 then
        local groupName
        -- Find a unique group name
        while (not groupName) or Group.getByName(groupName) do
          replacedGroupNameCounter = replacedGroupNameCounter + 1
          groupName = "autogft group #" .. replacedGroupNameCounter
        end
        local dcsGroupData = {
          ["route"] = {},
          ["units"] = groupUnits,
          ["name"] = groupName
        }
        -- Create a group
        local dcsGroup = coalition.addGroup(self.country, Group.Category.GROUND, dcsGroupData)

        -- Issue group to control zone
        self.groups[groupIndex].dcsGroup = dcsGroup
        self:moveGroupToTarget(dcsGroup)
      end
    end
    groupIndex = groupIndex + 1
  end
  return self
end

---
-- Scans the map once for any pre-existing units to control in this task force.
-- Groups with name starting with the scan prefix will be considered.
-- A task force will only take control of units according to the task force unit specification.
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce
function autogft_TaskForce:scanUnits(groupNamePrefix)
  local availableUnits = {}
  local coalitionID = coalition.getCountryCoalition(self.country)
  local groups = coalition.getGroups(coalitionID)
  for groupIndex = 1, #groups do
    local group = groups[groupIndex]
    if group:getName():find(groupNamePrefix) == 1 then
      local units = group:getUnits()
      for unitIndex = 1, #units do
        availableUnits[#availableUnits + 1] = units[unitIndex]
      end
    end
  end
  if #availableUnits > 0 then self:reinforceFromUnits(availableUnits) end
  return self
end

---
-- Stops the reinforcing/respawning timers
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce
function autogft_TaskForce:stopReinforcing()
  self.keepReinforcing = false
  return self
end
