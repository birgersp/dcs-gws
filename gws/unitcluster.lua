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

---
-- @param #UnitCluster self
-- @return #map<#string, #number>
function autogft_UnitCluster:getUnitTypeCount()
  local unitTypes = {}
  for i = 1, #self.units do
    local unit = self.units[i]
    local typeName = unit:getTypeName()
    if unitTypes[typeName] == nil then
      unitTypes[typeName] = 0
    end
    unitTypes[typeName] = unitTypes[typeName] + 1
  end
  return unitTypes
end
