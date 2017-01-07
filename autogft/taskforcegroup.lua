---
-- @module taskforcegroup

---
-- @type autogft_TaskForceGroup
-- @field #list<unitspec#autogft_UnitSpec> unitSpecs
-- @field DCSGroup#Group dcsGroup
autogft_TaskForceGroup = {}

---
-- @param #autogft_TaskForceGroup self
-- @param unitspec#autogft_UnitSpec unitSpec
-- @return #autogft_TaskForceGroup
function autogft_TaskForceGroup:new()
  self = setmetatable({}, {__index = autogft_TaskForceGroup})
  self.unitSpecs = {}
  return self
end

---
-- @param #autogft_TaskForceGroup self
-- @return #autogft_TaskForceGroup
function autogft_TaskForceGroup:exists()
  if self.dcsGroup then
    local units = self.dcsGroup:getUnits()
    if #units > 0 then
      for unitIndex = 1, #units do
        if units[unitIndex]:isExist() then return true end
      end
    end
  end
  self.dcsGroup = nil
  return false
end

---
-- @param #autogft_TaskForceGroup self
-- @param DCSUnit#Unit unit
-- @return #boolean
function autogft_TaskForceGroup:containsUnit(unit)
  if self.dcsGroup then
    local units = self.dcsGroup:getUnits()
    for unitIndex = 1, #units do
      if units[unitIndex]:getID() == unit:getID() then return true end
    end
  end
  return false
end

---
-- @param #autogft_TaskForceGroup self
-- @param unitspec#autogft_UnitSpec unitSpec
function autogft_TaskForceGroup:addUnitSpec(unitSpec)
  self.unitSpecs[#self.unitSpecs + 1] = unitSpec
  return self
end
