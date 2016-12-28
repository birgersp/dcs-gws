---
-- @type autogft_TaskForce
-- @field #number country
-- @field #list<#string> baseZones
-- @field #list<#autogft_ControlZone> targetZones
-- @field #number speed
-- @field #string formation
-- @field #string skill
-- @field #list<#autogft_UnitSpec> unitSpecs
-- @field #list<DCSGroup#Group> groups
-- @field #string target
autogft_TaskForce = {}
autogft_TaskForce.__index = autogft_TaskForce

---
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce
function autogft_TaskForce:new()
  self = setmetatable({}, autogft_TaskForce)
  self.country = -1
  self.baseZones = {}
  self.targetZones = {}
  self.speed = 100
  self.formation = "cone"
  self.skill = "High"
  self.unitSpecs = {}
  self.groups = {}
  self.target = ""
  return self
end

---
-- @param #autogft_TaskForce self
-- @param #number count
-- @param #string type
-- @return #autogft_TaskForce
function autogft_TaskForce:addUnitSpec(count, type)
  self.unitSpecs[#self.unitSpecs + 1] = autogft_UnitSpec:new(count, type)
  return self
end

---
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce
function autogft_TaskForce:cleanGroups()
  local newGroups = {}
  for i = 1, #self.groups do
    local group = self.groups[i]
    local units = group:getUnits()
    if #units > 0 then
      -- Verify that this group actually has existing units
      local hasExistingUnit = false
      local unitIndex = 1
      while unitIndex <= #units and not hasExistingUnit do
        hasExistingUnit = units[unitIndex]:isExist()
        unitIndex = unitIndex + 1
      end
      if hasExistingUnit then newGroups[#newGroups + 1] = group end
    end
  end

  self.groups = newGroups
  return self
end

---
-- @param #autogft_TaskForce self
-- @param #boolean useSpawning
-- @return #autogft_TaskForce
function autogft_TaskForce:reinforce(useSpawning)
  self:assertValid()
  -- If not spawning, use existing vehicles for as reinforcements
  local availableUnits
  if not useSpawning then
    availableUnits = autogft.getUnitsInZones(coalition.getCountryCoalition(self.country), self.baseZones)
  end
  local spawnedUnitCount = 0
  self:cleanGroups()
  local desiredUnits = {}
  for unitSpecIndex = 1, #self.unitSpecs do

    -- Determine desired replacement units of this spec
    local unitSpec = self.unitSpecs[unitSpecIndex]
    if desiredUnits[unitSpec.type] == nil then
      desiredUnits[unitSpec.type] = 0
    end
    desiredUnits[unitSpec.type] = desiredUnits[unitSpec.type] + unitSpec.count
    local replacements = desiredUnits[unitSpec.type]

    for groupIndex = 1, #self.groups do
      local existingUnits = autogft.countUnitsOfType(self.groups[groupIndex]:getUnits(), unitSpec.type)
      replacements = replacements - existingUnits
    end

    -- Get replacements
    if replacements <= 0 then return self end

    local units = {}
    local function addUnit(type, name, x, y, heading)
      units[#units + 1] = {
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

    local replacedUnits = 0
    local replacedUnitNameCounter = 0
    local replacedGroupNameCounter = 0

    -- Assign units to group
    if useSpawning then
      local spawnZoneIndex = math.random(#self.baseZones)
      local spawnZone = trigger.misc.getZone(self.baseZones[spawnZoneIndex])
      while replacedUnits < replacements do
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
        replacedUnits = replacedUnits + 1
      end
    else
      local availableUnitIndex = 1
      while replacedUnits < replacements and availableUnitIndex <= #availableUnits do
        local unit = availableUnits[availableUnitIndex]
        if unit:isExist()
          and unit:getTypeName() == unitSpec.type
          and not self:containsUnit(unit) then
          local x = unit:getPosition().p.x
          local y = unit:getPosition().p.z
          local heading = mist.getHeading(unit)
          addUnit(unitSpec.type, unit:getName(), x, y, heading)
          replacedUnits = replacedUnits + 1
        end
        availableUnitIndex = availableUnitIndex + 1
      end
    end

    if #units > 0 then
      local groupName
      -- Find a unique group name
      while (not groupName) or Group.getByName(groupName) do
        replacedGroupNameCounter = replacedGroupNameCounter + 1
        groupName = "autogft group #" .. replacedGroupNameCounter
      end
      local groupData = {
        ["route"] = {},
        ["units"] = units,
        ["name"] = groupName
      }
      -- Create a group
      local group = coalition.addGroup(self.country, Group.Category.GROUND, groupData)

      -- Issue group to control zone
      self.groups[#self.groups + 1] = group
      if self.target ~= nil then
        autogft.issueGroupTo(group, self.target)
      end
    end
  end
  return self
end

---
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce
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
-- @param #autogft_TaskForce self
-- @param #string zone
-- @return #autogft_TaskForce
function autogft_TaskForce:issueTo(zone)
  self:cleanGroups()
  for i = 1, #self.groups do
    autogft.issueGroupTo(self.groups[i], self.target, self.speed, self.formation)
  end
  return self
end

---
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce
function autogft_TaskForce:moveToTarget()
  self:issueTo(self.target)
  return self
end

---
-- @param #autogft_TaskForce self
-- @param #number timeIntervalSec
-- @return #autogft_TaskForce
function autogft_TaskForce:setTargetUpdateTimer(timeIntervalSec)
  self:assertValid()
  local function autoIssue()
    self:updateTarget()
    self:cleanGroups()
    self:moveToTarget()
    autogft.scheduleFunction(autoIssue, timeIntervalSec)
  end
  autogft.scheduleFunction(autoIssue, timeIntervalSec)
  return self
end

---
-- @param #autogft_TaskForce self
-- @param #number timeIntervalSec
-- @param #number maxReinforcementTime (optional)
-- @param #boolean useSpawning (optional)
-- @return #autogft_TaskForce
function autogft_TaskForce:setReinforceTimer(timeIntervalSec, maxReinforcementTime, useSpawning)
  self:assertValid()
  local keepReinforcing = true
  local function reinforce()
    if keepReinforcing then
      self:reinforce(useSpawning)
      autogft.scheduleFunction(reinforce, timeIntervalSec)
    end
  end

  autogft.scheduleFunction(reinforce, timeIntervalSec)

  if maxReinforcementTime ~= nil and maxReinforcementTime > 0 then
    local function killTimer()
      keepReinforcing = false
    end
    autogft.scheduleFunction(killTimer, maxReinforcementTime)
  end
  return self
end

---
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce
function autogft_TaskForce:enableDefaultTimers()
  self:setTargetUpdateTimer(autogft.DEFAULT_AUTO_ISSUE_DELAY)
  self:enableRespawnTimer(autogft.DEFAULT_AUTO_REINFORCE_DELAY)
  return self
end

---
-- @param #autogft_TaskForce self
-- @param DCSUnit#Unit unit
-- @return #boolean
function autogft_TaskForce:containsUnit(unit)
  for groupIndex = 1, #self.groups do
    local units = self.groups[groupIndex]:getUnits()
    for unitIndex = 1, #units do
      if units[unitIndex]:getID() == unit:getID() then return true end
    end
  end
  return false
end

---
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce
function autogft_TaskForce:respawn()
  return self:reinforce(true)
end

---
-- @param #autogft_TaskForce self
-- @param #number timeIntervalSec
-- @param #number maxRespawnTime (optional)
-- @return #autogft_TaskForce
function autogft_TaskForce:setRespawnTimer(timeIntervalSec, maxRespawnTime)
  return self:setReinforceTimer(timeIntervalSec, maxRespawnTime, true)
end

---
-- @param #autogft_TaskForce self
-- @param #number country
-- @return #autogft_TaskForce
function autogft_TaskForce:setCountry(country)
  self.country = country
  return self
end

---
-- @param #autogft_TaskForce self
-- @param #string baseZone
-- @return #autogft_TaskForce
function autogft_TaskForce:addBaseZone(baseZone)
  autogft.assertZoneExists(baseZone)
  self.baseZones[#self.baseZones + 1] = baseZone
  return self
end

---
-- @param #autogft_TaskForce self
-- @param #string targetZone
-- @return #autogft_TaskForce
function autogft_TaskForce:addTargetZone(targetZone)
  autogft.assertZoneExists(targetZone)
  local targetControlZone = autogft_ControlZone:new(targetZone)
  self.targetZones[#self.targetZones + 1] = targetControlZone
  if #self.targetZones == 1 then self.target = targetZone end
  return self
end

---
-- @param #autogft_TaskForce self
-- @return #autogft_TaskForce
function autogft_TaskForce:assertValid()
  assert(self.country ~= -1, "Task force country is missing. Use \"setCountry\" to set a country.")
  assert(#self.baseZones > 0, "Task force has no base zones. Use \"addBaseZone\" to add a base zone.")
  assert(#self.targetZones > 0, "Task force has no target zones. Use \"addTargetZone\" to add a target zone.")
  assert(#self.unitSpecs > 0, "Task force as no unit specifications. Use \"addUnitSpec\" to add a unit specification.")
  return self
end

---
-- @param #autogft_TaskForce self
-- @param #string skill
-- @return #autogft_TaskForce
function autogft_TaskForce:setSkill(skill)
  self.skill = skill
  return self
end
