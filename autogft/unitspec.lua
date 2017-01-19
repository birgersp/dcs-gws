---
-- @module UnitSpecification

---
-- @type UnitSpec
-- @field #number count
-- @field #string type
autogft_UnitSpec = {}
autogft_UnitSpec.__index = autogft_UnitSpec

---
-- @param #UnitSpec self
-- @param #number count
-- @param #string type
-- @return #UnitSpec
function autogft_UnitSpec:new(count, type)
  self = setmetatable({}, {__index = autogft_UnitSpec})
  self.count = count
  self.type = type
  return self
end