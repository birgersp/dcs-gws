---
-- AI units which can be set to automatically capture target zones, advance through captured zones and be reinforced when taking casualties.
-- @module Setup

---
-- @type Setup
-- @extends setupbase#SetupBase
autogft_Setup = autogft_SetupBase:extend()

---
-- Creates a new setup instance.
-- @param #Setup self
-- @return #Setup This instance (self)
function autogft_Setup:new()
  self = self:createInstance()
  local function autoInitialize()
    self:autoInitialize()
  end
  autogft.scheduleFunction(autoInitialize, 1)
  return self
end

---
-- Specifies the task force to stop using roads when advancing through the next tasks that are added.
-- @param #Setup self
-- @return #Setup
function autogft_Setup:stopUsingRoads()
  return autogft_SetupBase.stopUsingRoads(self)
end

---
-- Specifies the task force to use roads when advancing through the next tasks that are added.
-- @param #Setup self
-- @return #Setup
function autogft_Setup:startUsingRoads()
  return autogft_SetupBase.startUsingRoads(self)
end

---
-- Adds an intermidiate zone task.
-- Task force units advancing through the task list will move through this task zone to get to the next one.
-- @param #Setup self
-- @param #string zoneName
-- @return #Setup
function autogft_Setup:addIntermidiateZone(zoneName)
  return autogft_SetupBase.addIntermidiateZone(self, zoneName)
end

---
-- Adds another group specification to the task force.
-- After a group is added, use @{#Setup.addUnits} to add units.
-- See "unit-types" for a complete list of available unit types.
-- @param #Setup self
-- @return #Setup This instance (self)
function autogft_Setup:addTaskGroup()
  return autogft_SetupBase.addTaskGroup(self)
end

---
-- Sets the country ID of this task force.
-- @param #Setup self
-- @param #number country Country ID
-- @return #Setup This instance (self)
function autogft_Setup:setCountry(country)
  return autogft_SetupBase.setCountry(self, country)
end

---
-- Adds a base zone to the task force, which will be used for reinforcing.
-- @param #Setup self
-- @param #string zoneName Name of base zone
-- @return #Setup This instance (self)
function autogft_Setup:addBaseZone(zoneName)
  return autogft_SetupBase.addBaseZone(self, zoneName)
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
  return autogft_SetupBase.addControlZone(self, zoneName)
end

---
-- Sets the skill of the task force reinforcement units.
-- Skill alternatives are the same as in the mission editor: Any from "Average" to "Random".
-- @param #Setup self
-- @param #string skill New skill
-- @return #Setup This instance (self)
function autogft_Setup:setSkill(skill)
  return autogft_SetupBase.setSkill(self, skill)
end

---
-- Sets the desired speed of the task force units when advancing.
-- @param #Setup self
-- @param #boolean speed New speed (in knots)
-- @return #Setup This instance (self)
function autogft_Setup:setSpeed(speed)
  return autogft_SetupBase.setSpeed(self, speed)
end

---
-- Invokes @{#Setup.copyGroupsLayout} and @{#Setup.useExistingGroups}.
-- @param #Setup self
-- @param #string groupNamePrefix
-- @return #Setup
function autogft_Setup:scanUnits(groupNamePrefix)
  return autogft_SetupBase.scanUnits(self, groupNamePrefix)
end

---
-- Adds unit specifications to the most recently added group (see @{#Setup.addTaskGroup}) of the task force.
-- @param #Setup self
-- @return #Setup
function autogft_Setup:addUnits(count, type)
  return autogft_SetupBase.addUnits(self, count, type)
end

---
-- Sets the task force to only use pre-existing units when reinforcing. Always invoke this before units are added (not after).
-- @param #Setup self
-- @return #Setup
function autogft_Setup:useStaging()
  return autogft_SetupBase.useStaging(self)
end

---
-- Links a base zone to a group. Linked bases will be disabled for this task force if the group is destroyed (see @{Setup.checkBaseLinks}.
-- @param #Setup self
-- @param #string zoneName
-- @param #string groupName
-- @return #Setup
function autogft_Setup:linkBase(zoneName, groupName)
  return autogft_SetupBase.linkBase(self, zoneName, groupName)
end

---
-- Sets the task force to use a randomized unit spawner when reinforcing.
-- The random units must be specified with ${Setup.addRandomUnitAlternative}).
-- @param #Setup self
-- @return #Setup
function autogft_Setup:useRandomUnits()
  return autogft_SetupBase.useRandomUnits(self)
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
  return autogft_SetupBase.addRandomUnitAlternative(self, max, type, minimum)
end
