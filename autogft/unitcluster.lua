---
-- @module UnitCluster

---
-- @type UnitCluster
-- @extends class#Class
-- @field #list<DCSUnit#Unit> units
-- @field vector2#Vector2 midPoint
autogft_UnitCluster = autogft_Class:create()

---
-- @param #UnitCluster self
-- @param #list<DCSUnit#Unit> units
-- @param vector2#Vector2 midPoint
-- @return #UnitCluster
function autogft_UnitCluster:new(units, midPoint)
  self = self:createInstance()
  self.units = units
  self.midPoint = midPoint
  return self
end
