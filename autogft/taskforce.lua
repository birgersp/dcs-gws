---
-- AI units which can be set to automatically capture target zones, advance through captured zones and be reinforced when taking casualties.
-- @module TaskForce

---
-- @type TaskForce
-- @extends class#Class
-- @field #number coalition Coalition ID
-- @field #number speed Desired speed of moving units, in m/s (default: max speed)
-- @field #number maxDistanceKM Maximum distance of task force routes between each advancement, in kilometres (default: 10)
-- @field #boolean useRoads Wether the task force should use roads or not (default: false)
-- @field #string skill Skill of units (default: "High")
-- @field #number reinforcementTimerId Reinforcement timer identifier
-- @field #number stopReinforcementTimerId Reinforcement stopping timer identifier
-- @field #number advancementTimerId Advancement timer identifier
-- @field tasksequence#TaskSequence taskSequence Task sequence
-- @field reinforcer#SpecificUnitReinforcer reinforcer
-- @field group#Group lastAddedGroup
autogft_TaskForce = autogft_Class:create()

---
-- Creates a new task force instance.
-- To override, use ${TaskForce.setReinforceTimer} or ${TaskForce.setRespawnTimer}.
-- @param #TaskForce self
-- @return #TaskForce This instance (self)
function autogft_TaskForce:new()

  self = self:createInstance()
  self.coalition = nil
  self.speed = 9999
  self.maxDistanceKM = 10
  self.useRoads = false
  self.reinforcementTimerId = nil
  self.advancementTimerId = nil
  self.taskSequence = autogft_TaskSequence:new()
  self.reinforcer = autogft_RespawningReinforcer:new()
  self.lastAddedGroup = nil

  local function autoInitialize()
    self:autoInitialize()
  end
  autogft.scheduleFunction(autoInitialize, 2)

  return self
end

---
-- Specifies the task force to stop using roads when advancing through the next tasks that are added.
-- @param #TaskForce self
-- @return #TaskForce
function autogft_TaskForce:stopUsingRoads()
  self.useRoads = false
  return self
end

---
-- Specifies the task force to use roads when advancing through the next tasks that are added.
-- @param #TaskForce self
-- @return #TaskForce
function autogft_TaskForce:startUsingRoads()
  self.useRoads = true
  return self
end

---
-- Sets the maximum time reinforcements will keep coming.
-- @param #TaskForce self
-- @param #number time Time [seconds] until reinforcements will stop coming
-- @return #TaskForce
function autogft_TaskForce:setReinforceTimerMax(time)

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
-- @param #TaskForce self
-- @return #TaskForce
function autogft_TaskForce:autoInitialize()

  if not self.coalition then
    local unitsInBases = autogft.getUnitsInZones(coalition.side.RED, self.reinforcer.baseZones)
    if #unitsInBases == 0 then
      unitsInBases = autogft.getUnitsInZones(coalition.side.BLUE, self.reinforcer.baseZones)
    end
    assert(#unitsInBases > 0, "Could not determine task force coalition")
    self:setCountry(unitsInBases[1]:getCountry())
  end

  if self.reinforcer.groupsUnitSpecs.length <= 0 then
    self:autoAddUnitLayoutFromBases()
  end

  if #self.reinforcer.baseZones > 0 then
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
-- @param #TaskForce self
-- @return #TaskForce
function autogft_TaskForce:autoAddUnitLayout(units)

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
-- Looks through base zones for units and attempts to add the same layout to the task force (by invoking ${TaskForce.autoAddUnitLayout})
-- @param #TaskForce self
-- @return #TaskForce
function autogft_TaskForce:autoAddUnitLayoutFromBases()

  -- Determine coalition based on units in base zones
  local ownUnitsInBases = autogft.getUnitsInZones(self.coalition, self.reinforcer.baseZones)

  if #ownUnitsInBases > 0 then
    self:autoAddUnitLayout(ownUnitsInBases)
  end

  return self
end

---
-- Stops the advancement timer
-- @param #TaskForce self
-- @return #TaskForce
function autogft_TaskForce:stopAdvancementTimer()
  if self.advancementTimerId then
    timer.removeFunction(self.advancementTimerId)
    self.advancementTimerId = nil
  end
  return self
end

---
-- Adds an intermidiate zone task (see @{task#taskTypes.INTERMIDIATE}).
-- @param #TaskForce self
-- @param #string zoneName
-- @return #TaskForce
function autogft_TaskForce:addIntermidiateZone(zoneName)
  return self:addTask(autogft_CaptureTask:new(zoneName, self.coalition))
end

---
-- Adds a task to the task force
-- @param #TaskForce self
-- @param task#Task task
-- @return #TaskForce
function autogft_TaskForce:addTask(task)
  task.useRoads = self.useRoads
  task.speed = self.speed
  self.taskSequence:addTask(task)
  return self
end

---
-- Adds another group specification to the task force.
-- After a group is added, use @{#TaskForce.addUnits} to add units.
-- See "unit-types" for a complete list of available unit types.
-- @param #TaskForce self
-- @return #TaskForce This instance (self)
function autogft_TaskForce:addGroup()
  local unitSpec = autogft_UnitSpec:new(0, "")
  self.lastAddedGroup = autogft_Group:new(self.taskSequence)
  self.reinforcer.groupsUnitSpecs:put(self.lastAddedGroup, {})
  return self
end

---
-- Triggers task force reinforcing.
-- @param #TaskForce self
-- @return #TaskForce This instance (self)
function autogft_TaskForce:reinforce()
  self.reinforcer:reinforce()
end

---
-- Checks the status of tasks, and sets the current target task (@{#TaskForce.target}) of this task force.
-- @param #TaskForce self
function autogft_TaskForce:updateTarget()
  self.taskSequence:updateCurrentTask()
end

---
-- Sets all units to move towards the current target.
-- @param #TaskForce self
-- @return #TaskForce This instance (self)
function autogft_TaskForce:advance()
  assert(#self.taskSequence.tasks > 0, "Task force has no tasks. Use \"addControlTask\" to add a control zone task.")
  for _, group in pairs(self.reinforcer.groupsUnitSpecs.keys) do
    if group:exists() then group:advance() end
  end
  return self
end

---
-- Starts a timer which updates the current target zone, and issues the task force units to engage it on given time intervals.
-- Invokes @{#TaskForce.moveToTarget}.
-- @param #TaskForce self
-- @param #number timeInterval Seconds between each target update
-- @return #TaskForce This instance (self)
function autogft_TaskForce:setAdvancementTimer(timeInterval)
  self:stopAdvancementTimer()
  local function updateAndAdvance()
    self:updateTarget()
    self:advance()
    self.advancementTimerId = autogft.scheduleFunction(updateAndAdvance, timeInterval)
  end
  self.advancementTimerId = autogft.scheduleFunction(updateAndAdvance, timeInterval)
  return self
end

---
-- Starts a timer which reinforces the task force.
-- @param #TaskForce self
-- @param #number timeInterval Time [seconds] between each reinforcement
-- @param #boolean useSpawning (Optional) Specifies wether to spawn new units or use pre-existing units (default: false)
-- @return #TaskForce This instance (self)
function autogft_TaskForce:setReinforceTimer(timeInterval)
  self:stopReinforcing()

  assert(#self.reinforcer.baseZones > 0, "Cannot set reinforcing timer for this task force, no base zones are declared.")

  local function reinforce()
    self:reinforce()
    self.reinforcementTimerId = autogft.scheduleFunction(reinforce, timeInterval)
  end
  autogft.scheduleFunction(reinforce, 5)

  return self
end

---
-- Checks if a particular unit is present in this task force.
-- @param #TaskForce self
-- @param DCSUnit#Unit unit Unit in question
-- @return #boolean True if this task force contains the unit, false otherwise.
function autogft_TaskForce:containsUnit(unit)
  for _, group in pairs(self.reinforcer.groupsUnitSpecs.keys) do
    if group:containsUnit(unit) then return true end
  end
  return false
end

---
-- Sets the country ID of this task force.
-- @param #TaskForce self
-- @param #number country Country ID
-- @return #TaskForce This instance (self)
function autogft_TaskForce:setCountry(country)
  self.coalition = coalition.getCountryCoalition(country)
  -- Update capturing tasks coalition
  for i = 1, #self.taskSequence.tasks do
    local task = self.taskSequence.tasks[i]
    if task:instanceOf(autogft_CaptureTask) then
      task.coalition = self.coalition
    end
  end
  -- Update reinforcer
  self.reinforcer:setCountryID(country)
  return self
end

---
-- Adds a base zone to the task force, used for reinforcing (spawning or staging area).
-- @param #TaskForce self
-- @param #string zoneName Name of base zone
-- @return #TaskForce This instance (self)
function autogft_TaskForce:addBaseZone(zoneName)
  self.reinforcer:addBaseZone(zoneName)
  return self
end

---
-- Adds a control zone task (see @{task#taskTypes.CONTROL}).
-- @param #TaskForce self
-- @param #string zoneName Name of target zone
-- @return #TaskForce This instance (self)
function autogft_TaskForce:addControlZone(zoneName)
  return self:addTask(autogft_ControlTask:new(zoneName, self.coalition))
end

---
-- Sets the skill of the task force reinforcement units.
-- @param #TaskForce self
-- @param #string skill New skill
-- @return #TaskForce This instance (self)
function autogft_TaskForce:setSkill(skill)
  self.skill = skill
  return self
end

---
-- Sets the maximum distance of unit routes (see @{#TaskForce.maxDistanceKM}).
-- If set, this number constrains how far groups of the task force will move between each move command (advancement).
-- When units are moving towards a target, units will stop at this distance and wait for the next movement command.
-- This prevents lag when computing routes over long distances.
-- @param #TaskForce self
-- @param #number maxDistanceKM Maximum distance (kilometres)
-- @return #TaskForce This instance (self)
function autogft_TaskForce:setMaxRouteDistance(maxDistanceKM)
  self.maxDistanceKM = maxDistanceKM
  return self
end

---
-- Sets the desired speed of the task force units when advancing (see @{#TaskForce.speed}).
-- @param #TaskForce self
-- @param #boolean speed New speed (in knots)
-- @return #TaskForce This instance (self)
function autogft_TaskForce:setSpeed(speed)
  self.speed = speed
  if #self.taskSequence.tasks > 0 then self.taskSequence.tasks[#self.taskSequence.tasks].speed = self.speed end
  return self
end

---
-- Scans the map once for any pre-existing units to control in this task force.
-- Groups with name starting with the scan prefix will be considered.
-- A task force will only take control of units according to the task force unit specification.
-- @param #TaskForce self
-- @return #TaskForce
function autogft_TaskForce:scanUnits(groupNamePrefix)

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
    if self.reinforcer.groupsUnitSpecs.length <= 0 then
      self:autoAddUnitLayout(availableUnits)
    end
    self.reinforcer:reinforceFromUnits(availableUnits)
  end

  return self
end

---
-- Stops the reinforcing/respawning timers.
-- @param #TaskForce self
-- @return #TaskForce
function autogft_TaskForce:stopReinforcing()

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
-- Adds unit specifications to the most recently added group (see @{#TaskForce.addGroup}) of the task force.
-- @param #TaskForce self
-- @return #TaskForce
function autogft_TaskForce:addUnits(count, type)
  if not self.lastAddedGroup then self:addGroup() end
  local unitSpecs = self.reinforcer.groupsUnitSpecs:get(self.lastAddedGroup)
  unitSpecs[#unitSpecs + 1] = autogft_UnitSpec:new(count, type)
  return self
end

---
-- Disables respawning of units. Sets the task force to only use pre-existing units when reinforcing. If invoked, always invoke this before units are added.
-- @param #TaskForce self
-- @return #TaskForce
function autogft_TaskForce:useStaging()
  local baseMessage = "Cannot change task force reinforcing policy after base zones have been added."
  assert(#self.reinforcer.baseZones == 0, baseMessage .. " Invoke \"useStaging\" before adding base zones.")
  assert(self.reinforcer.groupsUnitSpecs.length == 0, baseMessage .. " Invoke \"useStaging\" before add units.")
  self.reinforcer = autogft_SelectingReinforcer:new()
  return self
end
