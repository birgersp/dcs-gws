---
-- AI units which can be set to automatically capture target zones, advance through captured zones and be reinforced when taking casualties.
-- @module Setup

---
-- @type Setup
-- @extends class#Class
-- @field taskforce#TaskForce taskForce
-- @field #number coalition
-- @field #number speed
-- @field #number maxDistanceKM
-- @field #boolean useRoads
-- @field #string skill
-- @field #number reinforcementTimerId
-- @field #number stopReinforcementTimerId
-- @field #number advancementTimerId
-- @field group#Group lastAddedGroup
-- @field map#Map baseLinks
autogft_Setup = autogft_Class:create()

---
-- Creates a new setup instance.
-- @param #Setup self
-- @return #Setup This instance (self)
function autogft_Setup:new()

  self = self:createInstance()
  self.taskForce = autogft_TaskForce:new()
  self.coalition = nil
  self.speed = 9999
  self.maxDistanceKM = 10
  self.useRoads = false
  self.reinforcementTimerId = nil
  self.advancementTimerId = nil
  self.lastAddedGroup = nil
  self.baseLinks = autogft_Map:new()

  local function autoInitialize()
    self:autoInitialize()
  end
  autogft.scheduleFunction(autoInitialize, 2)

  return self
end

---
-- Specifies the task force to stop using roads when advancing through the next tasks that are added.
-- @param #Setup self
-- @return #Setup
function autogft_Setup:stopUsingRoads()
  self.useRoads = false
  return self
end

---
-- Specifies the task force to use roads when advancing through the next tasks that are added.
-- @param #Setup self
-- @return #Setup
function autogft_Setup:startUsingRoads()
  self.useRoads = true
  return self
end

---
-- Sets the maximum time reinforcements will keep coming.
-- @param #Setup self
-- @param #number time Time [seconds] until reinforcements will stop coming
-- @return #Setup
function autogft_Setup:setReinforceTimerMax(time)

  if self.stopReinforcementTimerId then
    timer.removeFunction(self.stopReinforcementTimerId)
  end

  local function killTimer()
    self:stopReinforcing()
  end
  self.stopReinforcementTimerId = autogft.scheduleFunction(killTimer, time)

  return self
end

---
-- Automatically initializes the task force by starting timers (if not started) and adding groups and units (if not added).
-- Default reinforcement timer intervals is 600 seconds. Default advancement timer intervals is 300 seconds.
-- @param #Setup self
-- @return #Setup
function autogft_Setup:autoInitialize()

  if #self.taskForce.reinforcer.baseZones > 0 then
    if not self.coalition then
      local unitsInBases = autogft.getUnitsInZones(coalition.side.RED, self.taskForce.reinforcer.baseZones)
      if #unitsInBases == 0 then
        unitsInBases = autogft.getUnitsInZones(coalition.side.BLUE, self.taskForce.reinforcer.baseZones)
      end
      assert(#unitsInBases > 0, "Could not determine task force coalition, please set country.")
      self:setCountry(unitsInBases[1]:getCountry())
    end

    if self.taskForce.reinforcer:instanceOf(autogft_SpecificUnitReinforcer) then
      if self.taskForce.reinforcer.groupsUnitSpecs.length <= 0 then
        self:autoAddUnitLayoutFromBases()
      end
    end

    if not self.reinforcementTimerId then
      self:setReinforceTimer(600)
    end
  end

  if not self.advancementTimerId then
    self:setAdvancementTimer(300)
  end

  return self
end

---
-- Automatically adds groups and units.
-- Determines which groups and units that should be added to the task force by looking at a list of units and copying the layout.
-- @param #Setup self
-- @return #Setup
function autogft_Setup:autoAddUnitLayout(units)

  if not self.country then
    self:setCountry(units[1]:getCountry())
  end

  -- Create a table of groups {group = {type = count}}
  local groupUnits = {}

  -- Iterate through own base units
  for _, unit in pairs(units) do
    local dcsGroupId = unit:getGroup():getID()

    -- Check if table has this group
    if not groupUnits[dcsGroupId] then
      groupUnits[dcsGroupId] = {}
    end

    -- Check if group has this type
    local typeName = unit:getTypeName()
    if not groupUnits[dcsGroupId][typeName] then
      groupUnits[dcsGroupId][typeName] = 0
    end

    -- Count the number of units in this group of that type
    groupUnits[dcsGroupId][typeName] = groupUnits[dcsGroupId][typeName] + 1
  end

  -- Iterate through the table of groups, add groups and units
  for _, group in pairs(groupUnits) do
    self:addGroup()
    for type, count in pairs(group) do
      self:addUnits(count, type)
    end
  end

  return self
end

---
-- Looks through base zones for units and attempts to add the same layout to the task force (by invoking ${Setup.autoAddUnitLayout})
-- @param #Setup self
-- @return #Setup
function autogft_Setup:autoAddUnitLayoutFromBases()

  -- Determine coalition based on units in base zones
  local ownUnitsInBases = autogft.getUnitsInZones(self.coalition, self.taskForce.reinforcer.baseZones)

  if #ownUnitsInBases > 0 then
    self:autoAddUnitLayout(ownUnitsInBases)
    local reinforcer = self.taskForce.reinforcer --reinforcer#SpecificUnitReinforcer
    local tempReinforcer = autogft_SelectingReinforcer:new()
    tempReinforcer.groupsUnitSpecs = reinforcer.groupsUnitSpecs
    tempReinforcer:setCountryID(reinforcer.countryID)
    tempReinforcer:reinforceFromUnits(ownUnitsInBases)
  end

  return self
end

---
-- Stops the advancement timer
-- @param #Setup self
-- @return #Setup
function autogft_Setup:stopAdvancementTimer()
  if self.advancementTimerId then
    timer.removeFunction(self.advancementTimerId)
    self.advancementTimerId = nil
  end
  return self
end

---
-- Adds an intermidiate zone task.
-- Task force units advancing through the task list will move through this task zone to get to the next one.
-- @param #Setup self
-- @param #string zoneName
-- @return #Setup
function autogft_Setup:addIntermidiateZone(zoneName)
  return self:addTask(autogft_CaptureTask:new(zoneName, self.coalition))
end

---
-- Adds a task to the task force
-- @param #Setup self
-- @param task#Task task
-- @return #Setup
function autogft_Setup:addTask(task)
  task.useRoads = self.useRoads
  task.speed = self.speed
  self.taskForce.taskSequence:addTask(task)
  return self
end

---
-- Adds another group specification to the task force.
-- After a group is added, use @{#Setup.addUnits} to add units.
-- See "unit-types" for a complete list of available unit types.
-- @param #Setup self
-- @return #Setup This instance (self)
function autogft_Setup:addGroup()

  self.taskForce.groups[#self.taskForce.groups + 1] = autogft_Group:new(self.taskForce.taskSequence)
  self.lastAddedGroup = self.taskForce.groups[#self.taskForce.groups]
  if self.taskForce.reinforcer:instanceOf(autogft_SpecificUnitReinforcer) then
    self.taskForce.reinforcer.groupsUnitSpecs:put(self.lastAddedGroup, {})
  end
  return self
end

---
-- Starts a timer which updates the current target zone, and issues the task force units to engage it on given time intervals.
-- Invokes @{#Setup.moveToTarget}.
-- @param #Setup self
-- @param #number timeInterval Seconds between each target update
-- @return #Setup This instance (self)
function autogft_Setup:setAdvancementTimer(timeInterval)
  self:stopAdvancementTimer()
  local function updateAndAdvance()
    self.taskForce:updateTarget()
    self.taskForce:advance()
    self.advancementTimerId = autogft.scheduleFunction(updateAndAdvance, timeInterval)
  end
  self.advancementTimerId = autogft.scheduleFunction(updateAndAdvance, timeInterval)
  return self
end

---
-- Starts a timer which reinforces the task force on time intervals.
-- Every time interval, linked base zones are checked (see @{Setup.checkBaseLinks}).
-- If all base zones are disabled (due to linked groups being destroyed), the task force is not reinforced.
-- @param #Setup self
-- @param #number timeInterval Time [seconds] between each reinforcement
-- @return #Setup This instance (self)
function autogft_Setup:setReinforceTimer(timeInterval)
  self:stopReinforcing()

  assert(#self.taskForce.reinforcer.baseZones > 0, "Cannot set reinforcing timer for this task force, no base zones are declared.")

  local function reinforce()
    self:checkBaseLinks()
    if #self.taskForce.reinforcer.baseZones > 0 then
      self.taskForce:reinforce()
      self.reinforcementTimerId = autogft.scheduleFunction(reinforce, timeInterval)
    end
  end
  autogft.scheduleFunction(reinforce, 5)

  return self
end

---
-- Checks if a particular unit is present in this task force.
-- @param #Setup self
-- @param DCSUnit#Unit unit Unit in question
-- @return #boolean True if this task force contains the unit, false otherwise.
function autogft_Setup:containsUnit(unit)
  for _, group in pairs(self.taskForce.reinforcer.groupsUnitSpecs.keys) do
    if group:containsUnit(unit) then return true end
  end
  return false
end

---
-- Sets the country ID of this task force.
-- @param #Setup self
-- @param #number country Country ID
-- @return #Setup This instance (self)
function autogft_Setup:setCountry(country)
  self.coalition = coalition.getCountryCoalition(country)
  -- Update capturing tasks coalition
  for i = 1, #self.taskForce.taskSequence.tasks do
    local task = self.taskForce.taskSequence.tasks[i]
    if task:instanceOf(autogft_CaptureTask) then
      task.coalition = self.coalition
    end
  end
  -- Update reinforcer
  self.taskForce.reinforcer:setCountryID(country)
  return self
end

---
-- Adds a base zone to the task force, which will be used for reinforcing.
-- @param #Setup self
-- @param #string zoneName Name of base zone
-- @return #Setup This instance (self)
function autogft_Setup:addBaseZone(zoneName)
  self.taskForce.reinforcer:addBaseZone(zoneName)
  return self
end

---
-- Adds a control zone task.
-- The task force units will move to and attack this zone as long as there are enemy units present.
-- If enemy units re-appear, the task force will retake it.
-- Task force units advancing through the task list will move through this task zone to get to the next one.
-- @param #Setup self
-- @param #string zoneName Name of target zone
-- @return #Setup This instance (self)
function autogft_Setup:addControlZone(zoneName)
  return self:addTask(autogft_ControlTask:new(zoneName, self.coalition))
end

---
-- Sets the skill of the task force reinforcement units.
-- Skill alternatives are the same as in the mission editor: Any from "Average" to "Random".
-- @param #Setup self
-- @param #string skill New skill
-- @return #Setup This instance (self)
function autogft_Setup:setSkill(skill)
  self.skill = skill
  return self
end

---
-- Sets the maximum distance of unit routes (see @{#Setup.maxDistanceKM}).
-- If set, this number constrains how far groups of the task force will move between each move command (advancement).
-- When units are moving towards a target, units will stop at this distance and wait for the next movement command.
-- This prevents lag when computing routes over long distances.
-- @param #Setup self
-- @param #number maxDistanceKM Maximum distance (kilometres)
-- @return #Setup This instance (self)
function autogft_Setup:setMaxRouteDistance(maxDistanceKM)
  self.maxDistanceKM = maxDistanceKM
  return self
end

---
-- Sets the desired speed of the task force units when advancing (see @{#Setup.speed}).
-- @param #Setup self
-- @param #boolean speed New speed (in knots)
-- @return #Setup This instance (self)
function autogft_Setup:setSpeed(speed)
  self.speed = speed
  if #self.taskForce.taskSequence.tasks > 0 then self.taskForce.taskSequence.tasks[#self.taskForce.taskSequence.tasks].speed = self.speed end
  return self
end

---
-- Scans the map once for any pre-existing units to control in this task force.
-- Groups with name starting with the scan prefix will be considered.
-- A task force will only take control of units according to the task force unit specification (added units).
-- @param #Setup self
-- @return #Setup
function autogft_Setup:scanUnits(groupNamePrefix)

  local coalitionGroups = {
    coalition.getGroups(coalition.side.BLUE),
    coalition.getGroups(coalition.side.RED)
  }

  local availableUnits = {}

  local coalition = 1
  while coalition <= #coalitionGroups and #availableUnits == 0 do
    for _, group in pairs(coalitionGroups[coalition]) do
      if group:getName():find(groupNamePrefix) == 1 then
        local units = group:getUnits()
        for unitIndex = 1, #units do
          availableUnits[#availableUnits + 1] = units[unitIndex]
        end
      end
    end
    coalition = coalition + 1
  end

  if #availableUnits > 0 then
    if not self.country then
      self:setCountry(availableUnits[1]:getCountry())
    end
    self:autoAddUnitLayout(availableUnits)
    self.taskForce.reinforcer:reinforceFromUnits(availableUnits)
  end

  return self
end

---
-- Stops the reinforcing/respawning timers (see @{Setup.setReinforceTimer}).
-- @param #Setup self
-- @return #Setup
function autogft_Setup:stopReinforcing()

  if self.reinforcementTimerId then
    timer.removeFunction(self.reinforcementTimerId)
    self.reinforcementTimerId = nil
  end

  if self.stopReinforcementTimerId then
    timer.removeFunction(self.stopReinforcementTimerId)
    self.stopReinforcementTimerId = nil
  end

  return self
end

---
-- Adds unit specifications to the most recently added group (see @{#Setup.addGroup}) of the task force.
-- @param #Setup self
-- @return #Setup
function autogft_Setup:addUnits(count, type)
  assert(self.taskForce.reinforcer:instanceOf(autogft_SpecificUnitReinforcer), "Cannot add units with this function to this type of reinforcer.")
  if not self.lastAddedGroup then self:addGroup() end
  local unitSpecs = self.taskForce.reinforcer.groupsUnitSpecs:get(self.lastAddedGroup)
  unitSpecs[#unitSpecs + 1] = autogft_UnitSpec:new(count, type)
  return self
end

---
-- Sets the task force to only use pre-existing units when reinforcing. Always invoke this before units are added (not after).
-- @param #Setup self
-- @return #Setup
function autogft_Setup:useStaging()
  self:setReinforcer(autogft_SelectingReinforcer:new())
  return self
end

---
-- Links a base zone to a group. Linked bases will be disabled for this task force if the group is destroyed (see @{Setup.checkBaseLinks}.
-- @param #Setup self
-- @param #string zoneName
-- @param #string groupName
-- @return #Setup
function autogft_Setup:linkBase(zoneName, groupName)
  assert(trigger.misc.getZone(zoneName), "Cannot link base. Zone \"" .. zoneName .. "\" does not exist in this mission.")
  self.baseLinks:put(zoneName, groupName)
  return self
end

---
-- Checks all base zones with links to see if the specified unit still exists in the mission.
-- If the group linked with the base zone does not exist (is destroyed), the base zone is disabled for this task force.
-- @param #Setup self
function autogft_Setup:checkBaseLinks()

  for _, zoneName in pairs(self.baseLinks.keys) do
    local groupName = self.baseLinks:get(zoneName)
    local group = Group.getByName(groupName)
    -- If linked group is missing or destroyed
    if not autogft.groupExists(group) then
      local linkedBaseZone = trigger.misc.getZone(zoneName)
      -- Find zone in question
      local baseZone = nil
      local baseZoneI = 1
      while not baseZone and baseZoneI <= #self.taskForce.reinforcer.baseZones do
        local zone = self.taskForce.reinforcer.baseZones[baseZoneI]
        if autogft.compareZones(linkedBaseZone, zone) then
          baseZone = zone
        end
        baseZoneI = baseZoneI + 1
      end
      baseZoneI = baseZoneI - 1

      -- Remove zone from reinforcer
      if baseZone then
        self.taskForce.reinforcer.baseZones[baseZoneI] = nil
      end
    end
  end
end

---
-- Sets the task force to use a randomized unit spawner when reinforcing.
-- The random units must be specified with ${Setup.addRandomUnitAlternative}).
-- @param #Setup self
-- @return #Setup
function autogft_Setup:useRandomUnits()
  self:setReinforcer(autogft_RandomReinforcer:new())
  return self
end

---
-- Adds a random unit alternative, given a maximum count, type and minimum count.
-- When the task force is reinforced, a random number (between minimum and maximum) of units will be spawned for the task force group.
-- @param #Setup self
-- @param #number max
-- @param #string type
-- @param #number minimum
-- @return #Setup
function autogft_Setup:addRandomUnitAlternative(max, type, minimum)
  if not self.taskForce.reinforcer:instanceOf(autogft_RandomReinforcer) then
    self:useRandomUnits()
  end
  local reinforcer = self.taskForce.reinforcer --reinforcer#RandomReinforcer
  if not self.lastAddedGroup then self:addGroup() end
  local unitSpecs = self.taskForce.reinforcer.groupsUnitSpecs:get(self.lastAddedGroup)
  unitSpecs[#unitSpecs + 1] = autogft_RandomUnitSpec:new(max, type, minimum)
  return self
end

---
-- Performs checks to determine if the task force can change reinforcer.
-- @param #Setup self
function autogft_Setup:assertCanChangeReinforcer()
  local baseMessage = "Cannot change task force reinforcing policy: "
  assert(#self.taskForce.reinforcer.baseZones == 0, baseMessage .. "Base zones already added.")
  if self.taskForce.reinforcer:instanceOf(autogft_SpecificUnitReinforcer) then
    assert(self.taskForce.reinforcer.groupsUnitSpecs.length == 0, baseMessage .. "Groups/units already added.")
  end
end

---
-- Sets the reinforcer of the task force.
-- @param #Setup self
-- @param reinforcer#Reinforcer reinforcer
function autogft_Setup:setReinforcer(reinforcer)
  self:assertCanChangeReinforcer()
  reinforcer.unitSkill = self.skill
  reinforcer.countryID = self.taskForce.reinforcer.countryID
  self.taskForce.reinforcer = reinforcer
end
