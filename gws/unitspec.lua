---
-- @module UnitSpecification

---
-- @type UnitSpec
-- @extends class#Class
-- @field #number count
-- @field #string type
gws_UnitSpec = gws_Class:create()

---
-- @param #UnitSpec self
-- @param #number count
-- @param #string type
-- @return #UnitSpec
function gws_UnitSpec:new(count, type)
  self = self:createInstance()
  self.count = count
  self.type = type
  return self
end