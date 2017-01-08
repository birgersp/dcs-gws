---
-- AI units which can be set to automatically capture target zones, advance through captured zones and be reinforced when taking casualties.
-- @module taskforce

---
-- @type autogft_TaskForce
-- @field #number country Country ID
-- @field #list<#string> baseZones List of base zones
-- @field #list<taskforcetask#autogft_TaskForceTask> tasks List of tasks
-- @field #number speed Desired speed of moving units, in knots (default: max speed)
-- @field #number maxDistanceKM Maximum distance of task force routes between each advancement, in kilometres (default: 10)
-- @field #string formation Formation of moving units (default: "cone")
-- @field #boolean useRoads Wether the task force should use roads or not (default: false)
-- @field #string skill Skill of units (default: "High")
-- @field #list<taskforcegroup#autogft_TaskForceGroup> groups Groups of the task force
-- @field #number target Current target zone index
-- @field #number reinforcementTimerId Reinforcement timer identifier
-- @field #number stopReinforcementTimerId Reinforcement stopping timer identifier
autogft_TaskForce = {}

---
-- Creates a new task force instance.
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:new()
  self = setmetatable({}, {__index = autogft_TaskForce})
  self.country = country.id.RUSSIA
  self.baseZones = {}
  self.tasks = {}
  self.speed = 100
  self.maxDistanceKM = 10
  self.formation = "cone"
  self.useRoads = false
  self.skill = "High"
  self.groups = {}
  self.target = 1
  self.reinforcementTimerId = nil
  self.stopReinforcementTimerId = nil
  return self
end

---
-- Adds a task to the task force
-- @param #autogft_TaskForce self
-- @param #autogft_TaskForceTask task
-- @return #autogft_TaskForce
function autogft_TaskForce:addTask(task)
  self.tasks[#self.tasks + 1] = task
  return self
end

---
-- Adds a group specification to declare which units the task force shall consist of.
-- If no count or type is specified, an empty group is added. Units can be added to the group with @{#autogft_TaskForce.addUnits}.
-- See "unit-types" for a complete list of available unit types.
-- @param #autogft_TaskForce self
-- @param #number count (Optional) Number of units for the group
-- @param #string type (Optional) Type of unit
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:addGroup(count, type)
  local unitSpec = autogft_UnitSpec:new(count, type)
  self.groups[#self.groups + 1] = autogft_TaskForceGroup:new(self)
  if count and type then
    self:addUnits(count, type)
  end
  return self
end

---
-- Triggers task force reinforcing (invokes @{#autogft_TaskForce.reinforceFromUnits}) by either looking up units in base zones or spawning new units.
-- @param #autogft_TaskForce self
-- @param #boolean useSpawning (Optional) Specifies wether to spawn new units or use pre-existing units (default is false, using units located in base)
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:reinforce(useSpawning)
  assert(#self.groups > 0, "Task force as no group specifications. Use \"addGroup\" to add a specification.")
  assert(#self.baseZones > 0, "Task force has no base zones. Use \"addBaseZone\" to add a base zone.")
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

  local done = false
  local newTarget

  local ownCoalition = coalition.getCountryCoalition(self.country)
  local enemyCoalition
  if ownCoalition == coalition.side.RED then
    enemyCoalition = coalition.side.BLUE
  else
    enemyCoalition = coalition.side.RED
  end

  local taskIndex = 1
  while not newTarget and taskIndex <= #self.tasks do
    local task = self.tasks[taskIndex]

    if task.type == autogft_taskTypes.CONTROL then
      local enemyUnits = autogft_getUnitsInZones(enemyCoalition, {task.zoneName})
      if #enemyUnits > 0 then
        task.cleared = false
      else
        local ownUnits = autogft_getUnitsInZones(ownCoalition, {task.zoneName})
        if #ownUnits > 0 then
          task.cleared = true
        end
      end
    elseif task.type == autogft_taskTypes.CAPTURE then
      local enemyUnits = autogft_getUnitsInZones(enemyCoalition, {task.zoneName})
      if not task.cleared then
        if #enemyUnits <= 0 then
          local ownUnits = autogft_getUnitsInZones(ownCoalition, {task.zoneName})
          if #ownUnits > 0 then
            task.cleared = true
          end
        end
      end
    else
      task.cleared = true
    end
    if not task.cleared then
      newTarget = taskIndex
    else
      taskIndex = taskIndex + 1
    end
  end
  
  if newTarget then self.target = newTarget end
  return self
end

---
-- Sets all units to move towards the current target.
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:advance()
  assert(#self.tasks > 0, "Task force has no tasks. Use \"addControlTask\" to add a control zone task.")
  for i = 1, #self.groups do
    if self.groups[i]:exists() then self.groups[i]:advance() end
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
  local function autoIssue()
    self:updateTarget()
    self:advance()
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
  self:stopReinforcing()

  local function reinforce()
    self:reinforce(useSpawning)
    self.reinforcementTimerId = autogft_scheduleFunction(reinforce, timeInterval)
  end
  self.reinforcementTimerId = autogft_scheduleFunction(reinforce, timeInterval)

  if maxTime ~= nil and maxTime > 0 then
    local function killTimer()
      self:stopReinforcing()
    end
    self.stopReinforcementTimerId = autogft_scheduleFunction(killTimer, maxTime)
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
  local task = autogft_TaskForceTask:new(name, autogft_taskTypes.CONTROL)
  return self:addTask(task)
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
-- @param #string groupNamePrefix (Optional) Name prefix to use when creating groups
-- @return #autogft_TaskForce This instance (self)
function autogft_TaskForce:reinforceFromUnits(availableUnits, groupNamePrefix)

  local finished = false
  local spawnedUnitCount, takenUnits, replacedUnitNameCounter, addedGroupUnitsCount

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
              local heading = mist.getHeading(unit)
              addGroupUnit(unitSpec.type, unit:getName(), x, y, heading)
              takenUnits[availableUnitIndex] = true
            end
            availableUnitIndex = availableUnitIndex + 1
          end
          if #takenUnits >= #availableUnits then finished = true end
        else
          -- Spawn new units
          local spawnZoneIndex = math.random(#self.baseZones)
          local spawnZone = trigger.misc.getZone(self.baseZones[spawnZoneIndex])

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
  if #availableUnits > 0 then self:reinforceFromUnits(availableUnits, groupNamePrefix) end
  return self
end

---
-- Stops the reinforcing/respawning timers.
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce
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
-- Adds unit specifications to the most recently added group (see @{#autogft_TaskForce.addGroup}) of the task force.
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce
function autogft_TaskForce:addUnits(count, type)
  assert(#self.groups > 0, "Task force as no group specifications. Use \"addGroup\" to add a unit specification.")
  self.groups[#self.groups]:addUnitSpec(autogft_UnitSpec:new(count, type))
  return self
end
