---
-- AI units which can be set to automatically capture target zones, advance through captured zones and be reinforced when taking casualties.
-- @module TaskForce

---
-- @type TaskForce
-- @extends class#Class
-- @field #number country Country ID
-- @field #number coalition Coalition ID
-- @field #list<#string> baseZones List of base zones
-- @field #number speed Desired speed of moving units, in m/s (default: max speed)
-- @field #number maxDistanceKM Maximum distance of task force routes between each advancement, in kilometres (default: 10)
-- @field #boolean useRoads Wether the task force should use roads or not (default: false)
-- @field #string skill Skill of units (default: "High")
-- @field #list<group#Group> groups Groups of the task force
-- @field #number reinforcementTimerId Reinforcement timer identifier
-- @field #number stopReinforcementTimerId Reinforcement stopping timer identifier
-- @field #number advancementTimerId Advancement timer identifier
-- @field tasksequence#TaskSequence taskSequence Task sequence
autogft_TaskForce = autogft_Class:create()

---
-- Creates a new task force instance.
-- To override, use ${TaskForce.setReinforceTimer} or ${TaskForce.setRespawnTimer}.
-- @param #TaskForce self
-- @return #TaskForce This instance (self)
function autogft_TaskForce:new()

  self = self:createInstance()
  self.country = nil
  self.baseZones = {}
  self.speed = 9999
  self.maxDistanceKM = 10
  self.useRoads = false
  self.skill = "High"
  self.groups = {}
  self.taskSequence = autogft_TaskSequence:new()

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

  if #self.groups <= 0 then
    self:autoAddUnitLayoutFromBases()
  end

  if #self.baseZones > 0 then
    if not self.reinforcementTimerId then
      self:setRespawnTimer(600)
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
  local ownUnitsInBases = autogft.getUnitsInZones(coalition.side.BLUE, self.baseZones)
  if #ownUnitsInBases <= 0 then
    ownUnitsInBases = autogft.getUnitsInZones(coalition.side.RED, self.baseZones)
  end

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
  local unitSpec = autogft_UnitSpec:new(count, type)
  self.groups[#self.groups + 1] = autogft_Group:new(self.taskSequence)
  return self
end

---
-- Triggers task force reinforcing (invokes @{#TaskForce.reinforceFromUnits}) by either looking up units in base zones or spawning new units.
-- @param #TaskForce self
-- @param #boolean useSpawning (Optional) Specifies wether to spawn new units or use pre-existing units (default is false, using units located in base)
-- @return #TaskForce This instance (self)
function autogft_TaskForce:reinforce(useSpawning)
  assert(#self.groups > 0, "Task force as no group/unit specifications.")
  assert(#self.baseZones > 0, "Task force has no base zones. Use \"addBaseZone\" to add a base zone.")
  local availableUnits
  if not useSpawning then

    availableUnits = {}
    if not self.country then

      availableUnits = autogft.getUnitsInZones(coalition.side.BLUE, self.baseZones)
      if #availableUnits <= 0 then
        availableUnits = autogft.getUnitsInZones(coalition.side.BLUE, self.baseZones)
      end

      if #availableUnits > 0 then
        self:setCountry(availableUnits[1]:getCountry())
      end

    else
      availableUnits = autogft.getUnitsInZones(self.coalition, self.baseZones)
    end
  end

  return self:reinforceFromUnits(availableUnits)
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
  for i = 1, #self.groups do
    if self.groups[i]:exists() then self.groups[i]:advance() end
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
function autogft_TaskForce:setReinforceTimer(timeInterval, useSpawning)
  self:stopReinforcing()

  assert(#self.baseZones > 0, "Cannot set reinforce/respawning timer for this Task Force, no base zones are declared.")

  local function reinforce()
    self:reinforce(useSpawning)
    self.reinforcementTimerId = autogft.scheduleFunction(reinforce, timeInterval)
  end
  autogft.scheduleFunction(reinforce, 1)

  return self
end

---
-- Checks if a particular unit is present in this task force.
-- @param #TaskForce self
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
-- @param #TaskForce self
-- @return #TaskForce This instance (self)
function autogft_TaskForce:respawn()
  return self:reinforce(true)
end

---
-- Starts a timer which reinforces the task force by spawning new units.
-- @param #TaskForce self
-- @param #number timeInterval Time [seconds] between each reinforcement
-- @return #TaskForce This instance (self)
function autogft_TaskForce:setRespawnTimer(timeInterval)
  return self:setReinforceTimer(timeInterval, true)
end

---
-- Sets the country ID of this task force.
-- @param #TaskForce self
-- @param #number country Country ID
-- @return #TaskForce This instance (self)
function autogft_TaskForce:setCountry(country)
  self.country = country
  self.coalition = coalition.getCountryCoalition(country)
  -- Update capturing tasks coalition
  for i = 1, #self.taskSequence.tasks do
    local task = self.taskSequence.tasks[i]
    if task:instanceOf(autogft_CaptureTask) then
      task.coalition = self.coalition
    end
  end
  return self
end

---
-- Adds a base zone to the task force, used for reinforcing (spawning or staging area).
-- @param #TaskForce self
-- @param #string baseZone Name of base zone
-- @return #TaskForce This instance (self)
function autogft_TaskForce:addBaseZone(baseZone)
  autogft.assertZoneExists(baseZone)
  self.baseZones[#self.baseZones + 1] = baseZone
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
-- Attempts to reinforce the task force according to its unit specifications using a list of available units.
-- Reinforced units will immidiately start moving towards current target zone (see @{#TaskForce.target}).
-- @param #TaskForce self
-- @param #list<DCSUnit#Unit> availableUnits (Optional) Available units (if this list is not specified, units will be spawned)
-- @param #string groupNamePrefix (Optional) Name prefix to use when creating groups
-- @return #TaskForce This instance (self)
function autogft_TaskForce:reinforceFromUnits(availableUnits, groupNamePrefix)

  local finished = false
  local spawnedUnitCount, takenUnits, replacedUnitNameCounter, addedGroupUnitsCount, spawnZone

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

      local groupUnits = {}
      local function addGroupUnit(type, name, x, y, heading)
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
        addedGroupUnitsCount = addedGroupUnitsCount + 1
      end

      if not availableUnits then
        spawnZone = trigger.misc.getZone(self.baseZones[math.random(#self.baseZones)])
      end

      for unitSpecIndex = 1, #group.unitSpecs do
        local unitSpec = group.unitSpecs[unitSpecIndex]

        addedGroupUnitsCount = 0

        if availableUnits then
          -- Use pre-existing units
          local availableUnitIndex = 1
          while addedGroupUnitsCount < unitSpec.count and availableUnitIndex <= #availableUnits do
            local unit = availableUnits[availableUnitIndex]
            if unit:isExist()
              and not takenUnits[availableUnitIndex]
              and unit:getTypeName() == unitSpec.type then
              local x = unit:getPosition().p.x
              local y = unit:getPosition().p.z
              local heading = autogft.getUnitHeading(unit)
              addGroupUnit(unitSpec.type, unit:getName(), x, y, heading)
              takenUnits[availableUnitIndex] = true
            end
            availableUnitIndex = availableUnitIndex + 1
          end
          if #takenUnits >= #availableUnits then finished = true end
        else
          -- Spawn new units
          while addedGroupUnitsCount < unitSpec.count do
            local name
            -- Find a unique unit name
            while (not name) or Unit.getByName(name) do
              replacedUnitNameCounter = replacedUnitNameCounter + 1
              name = "autogft unit #" .. replacedUnitNameCounter
            end
            local x = spawnZone.point.x + 15 * spawnedUnitCount
            local y = spawnZone.point.z - 15 * spawnedUnitCount
            addGroupUnit(unitSpec.type, name, x, y, 0)
            spawnedUnitCount = spawnedUnitCount + 1
          end
        end
      end
      if #groupUnits > 0 then
        local groupName
        -- Find a unique group name
        while (not groupName) or Group.getByName(groupName) do
          replacedGroupNameCounter = replacedGroupNameCounter + 1
          groupName = "autogft group #" .. replacedGroupNameCounter
          if groupNamePrefix then groupName = groupNamePrefix .. "-" .. groupName end
        end
        local dcsGroupData = {
          ["route"] = {},
          ["units"] = groupUnits,
          ["name"] = groupName
        }

        -- Create a group
        local dcsGroup = coalition.addGroup(self.country, Group.Category.GROUND, dcsGroupData)

        -- Issue group to control zone
        self.groups[groupIndex]:setDCSGroup(dcsGroup)
        self.groups[groupIndex]:advance()
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
    if #self.groups <= 0 then
      self:autoAddUnitLayout(availableUnits)
    end
    self:reinforceFromUnits(availableUnits, groupNamePrefix)
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
  if #self.groups <= 0 then self:addGroup() end
  self.groups[#self.groups]:addUnitSpec(autogft_UnitSpec:new(count, type))
  return self
end
