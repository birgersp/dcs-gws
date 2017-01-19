---
-- @module UnitSpecification

---
-- @type UnitSpec
-- @extends class#Class
-- @field #number count
-- @field #string type
autogft_UnitSpec = autogft_Class:create()

---
-- @param #UnitSpec self
-- @param #number count
-- @param #string type
-- @return #UnitSpec
function autogft_UnitSpec:new(count, type)
  self = self:createInstance()
  self.count = count
  self.type = type
  return self
end