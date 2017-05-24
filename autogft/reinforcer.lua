---
-- @module Reinforcer

---
-- @type ReinforcerUnit
-- @extends class#Class
-- @field #string type
-- @field #string name
-- @field #number x
-- @field #number y
-- @field #number heading
autogft_ReinforcerUnit = autogft_Class:create()

---
-- @param #ReinforcerUnit self
-- @param #string type
-- @param #string name
-- @param #number x
-- @param #number y
-- @param #number heading
-- @return #ReinforcerUnit
function autogft_ReinforcerUnit:new(type, name, x, y, heading)
  self = self:createInstance()
  self.type = type
  self.name = name
  self.x = x
  self.y = y
  self.heading = heading
  return self
end

---
-- @type Reinforcer
-- @extends class#Class
-- @field #list<DCSZone#Zone> baseZones
-- @field #number countryID
-- @field #string unitSkill
autogft_Reinforcer = autogft_Class:create()

---
-- @param #Reinforcer self
-- @return #Reinforcer
function autogft_Reinforcer:new()
  self = self:createInstance()
  self.baseZones = {}
  self.countryID = nil
  self.unitSkill = "High"
  return self
end

---
-- @param #Reinforcer self
-- @param #string name
function autogft_Reinforcer:addBaseZone(name)
  local zone = trigger.misc.getZone(name)
  assert(zone, "Zone \"" .. name .. "\" does not exist in this mission.")
  self.baseZones[#self.baseZones + 1] = zone
end

---
-- @param #Reinforcer self
-- @param #number id
function autogft_Reinforcer:setCountryID(id)
  self.countryID = id
end

---
-- @param #Reinforcer self
-- @param taskgroup#TaskGroup group
-- @param #list<#ReinforcerUnit> units
function autogft_Reinforcer:addGroupUnits(group, units)

  local dcsGroupUnits = {}
  for i = 1, #units do
    local unit = units[i] --#ReinforcerUnit
    dcsGroupUnits[i] = {
      ["type"] = unit.type,
      ["transportable"] =
      {
        ["randomTransportable"] = false,
      },
      ["x"] = unit.x,
      ["y"] = unit.y,
      ["heading"] = unit.heading,
      ["name"] = unit.name,
      ["skill"] = self.unitSkill,
      ["playerCanDrive"] = true
    }
  end

  local dcsGroupData = {
    ["route"] = {},
    ["units"] = dcsGroupUnits,
    ["name"] = autogft.getUniqueGroupName()
  }

  local dcsGroup = coalition.addGroup(self.countryID, Group.Category.GROUND, dcsGroupData)
  group:setDCSGroup(dcsGroup)
end

---
-- @param #Reinforcer self
function autogft_Reinforcer:assertHasBaseZones()
  assert(#self.baseZones > 0, "No base zones specified. Use \"addBaseZone\" to add a base zone.")
end

---
-- @param #Reinforcer self
function autogft_Reinforcer:reinforce()
  self:throwAbstractFunctionError()
end

---
-- @type SpecificUnitReinforcer
-- @field map#Map groupsUnitSpecs
-- @extends #Reinforcer
autogft_SpecificUnitReinforcer = autogft_Reinforcer:extend()

---
-- @param #SpecificUnitReinforcer self
-- @return #SpecificUnitReinforcer
function autogft_SpecificUnitReinforcer:new()
  self = self:createInstance()
  self.groupsUnitSpecs = autogft_Map:new()
  return self
end

---
-- @param #SpecificUnitReinforcer self
function autogft_SpecificUnitReinforcer:assertHasGroupsUnitSpecs()
  assert(self.groupsUnitSpecs.length, "No group unit specifications. Use \"setGroupUnitSpecs\" to set group unit specifications.")
end

---
-- @param #SpecificUnitReinforcer self
-- @param #list<DCSUnit#Unit> availableUnits
function autogft_SpecificUnitReinforcer:reinforceFromUnits(availableUnits)
  local takenUnitIndices = {}
  for groupID, _ in pairs(self.groupsUnitSpecs.keys) do
    local group = self.groupsUnitSpecs.keys[groupID] --taskgroup#TaskGroup

    if not group:exists() then
      local newUnits = {}
      local unitSpecs = self.groupsUnitSpecs:get(group)
      for unitSpecIndex = 1, #unitSpecs do
        local unitSpec = unitSpecs[unitSpecIndex] --unitspec#UnitSpec

        local addedGroupUnitsCount = 0

        local availableUnitIndex = 1
        while addedGroupUnitsCount < unitSpec.count and availableUnitIndex <= #availableUnits do
          local unit = availableUnits[availableUnitIndex]
          if unit:isExist()
            and not takenUnitIndices[availableUnitIndex]
            and unit:getTypeName() == unitSpec.type then
            local x = unit:getPosition().p.x
            local y = unit:getPosition().p.z
            local heading = autogft.getUnitHeading(unit)

            newUnits[#newUnits + 1] = autogft_ReinforcerUnit:new(unitSpec.type, unit:getName(), x, y, heading)
            takenUnitIndices[availableUnitIndex] = true
            addedGroupUnitsCount = addedGroupUnitsCount + 1
          end
          availableUnitIndex = availableUnitIndex + 1
        end

        if #takenUnitIndices >= #availableUnits then
          break
        end
      end

      self:addGroupUnits(group, newUnits)
      group:advance()
    end
  end
end

---
-- @type RespawningReinforcer
-- @extends #SpecificUnitReinforcer
-- @field #number uniqueUnitNameCount
autogft_RespawningReinforcer = autogft_SpecificUnitReinforcer:extend()

---
-- @param #RespawningReinforcer self
-- @return #RespawningReinforcer
function autogft_RespawningReinforcer:new()
  self = self:createInstance()
  self.uniqueUnitNameCount = 0
  return self
end

---
-- @param #RespawningReinforcer self
-- @return #string
function autogft_RespawningReinforcer:getUniqueUnitName()
  local name
  -- Find a unique unit name
  while (not name) or Unit.getByName(name) do
    self.uniqueUnitNameCount = self.uniqueUnitNameCount + 1
    name = "autogft unit #" .. self.uniqueUnitNameCount
  end
  return name
end

---
-- @param #RespawningReinforcer self
function autogft_RespawningReinforcer:reinforce()

  self:assertHasBaseZones()
  self:assertHasGroupsUnitSpecs()

  local spawnZone = self.baseZones[math.random(#self.baseZones)]
  local spawnedUnitCount = 0

  for groupID, _ in pairs(self.groupsUnitSpecs.keys) do
    local group = self.groupsUnitSpecs.keys[groupID] --taskgroup#TaskGroup

    if not group:exists() then
      local newUnits = {}
      local unitSpecs = self.groupsUnitSpecs:get(group)
      for unitSpecIndex = 1, #unitSpecs do
        local unitSpec = unitSpecs[unitSpecIndex] --unitspec#UnitSpec
        for unitI = 1, unitSpec.count do
          local x = spawnZone.point.x + 15 * spawnedUnitCount
          local y = spawnZone.point.z - 15 * spawnedUnitCount
          newUnits[#newUnits + 1] = autogft_ReinforcerUnit:new(unitSpec.type, self:getUniqueUnitName(), x, y, 0)
          spawnedUnitCount = spawnedUnitCount + 1
        end
      end

      self:addGroupUnits(group, newUnits)
      group:advance()

    end
  end
end

---
-- @type SelectingReinforcer
-- @extends #SpecificUnitReinforcer
-- @field #number coalitionID
autogft_SelectingReinforcer = autogft_SpecificUnitReinforcer:extend()

---
-- @param #SelectingReinforcer self
-- @return #SelectingReinforcer
function autogft_SelectingReinforcer:new()
  self = autogft_SelectingReinforcer:createInstance()
  self.coalitionID = nil
  return self
end

---
-- @param #SelectingReinforcer self
-- @param #number id
function autogft_SelectingReinforcer:setCountryID(id)
  autogft_Reinforcer.setCountryID(self, id)
  self.coalitionID = coalition.getCountryCoalition(self.countryID)
end

---
-- @param #SelectingReinforcer self
function autogft_SelectingReinforcer:reinforce()

  self:assertHasBaseZones()
  self:assertHasGroupsUnitSpecs()

  local availableUnits = autogft.getUnitsInZones(self.coalitionID, self.baseZones)
  if #availableUnits > 0 then
    autogft_SpecificUnitReinforcer.reinforceFromUnits(self, availableUnits)
  end
end

---
-- @type RandomUnitSpec
-- @extends unitspec#UnitSpec
-- @field #number minimum
-- @field #number diff
autogft_RandomUnitSpec = autogft_UnitSpec:extend()

---
-- @param #RandomUnitSpec self
-- @param #number
function autogft_RandomUnitSpec:new(count, type, minimum)
  if minimum == nil then minimum = 0 end
  self = self:createInstance(autogft_UnitSpec:new(count, type))
  self.minimum = minimum
  self.diff = count - minimum
  return self
end

---
-- @type RandomReinforcer
-- @extends #SpecificUnitReinforcer
-- @field #RespawningReinforcer respawningReinforcer
autogft_RandomReinforcer = autogft_SpecificUnitReinforcer:extend()

---
-- @param #RandomReinforcer self
-- @return #RandomReinforcer
function autogft_RandomReinforcer:new()
  self = self:createInstance()
  self.respawningReinforcer = autogft_RespawningReinforcer:new()
  self.respawningReinforcer.baseZones = self.baseZones
  return self
end

---
-- @param #RandomReinforcer self
function autogft_RandomReinforcer:reinforce()
  for _, group in pairs(self.groupsUnitSpecs.keys) do
    local randomUnitSpecs = self.groupsUnitSpecs:get(group)
    local unitSpecs = {}
    for i = 1, #randomUnitSpecs do
      local unitSpec = randomUnitSpecs[i] --unitspec#UnitSpec

      local count = unitSpec.count
      if unitSpec:instanceOf(autogft_RandomUnitSpec) then
        local random = math.floor(math.random(unitSpec.diff + 0.9999))
        count = unitSpec.minimum + random
      end
      unitSpecs[#unitSpecs + 1] = autogft_UnitSpec:new(count, unitSpec.type)
    end
    self.respawningReinforcer.groupsUnitSpecs:put(group, unitSpecs)
  end
  self.respawningReinforcer:reinforce()
end

---
-- @param #RandomReinforcer self
-- @param taskgroup#TaskGroup group
-- @param #list<#RandomUnitSpec> randomUnitSpecs
function autogft_RandomReinforcer:setGroupUnitSpecs(group, randomUnitSpecs)
  self.groupsUnitSpecs:put(group, randomUnitSpecs)
end

---
-- @param #RandomReinforcer self
-- @param #number id
function autogft_RandomReinforcer:setCountryID(id)
  autogft_Reinforcer.setCountryID(self, id)
  self.respawningReinforcer:setCountryID(id)
end
