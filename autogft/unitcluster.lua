---
-- @module UnitCluster

---
-- @type UnitCluster
-- @extends class#Class
-- @field #list<#string> unitNames
-- @field DCSTypes#Vec2 midPoint
autogft_UnitCluster = autogft_Class:create()

---
-- @param #UnitCluster self
-- @return #UnitCluster
function autogft_UnitCluster:new()
  self = self:createInstance()
  self.unitNames = {}
  self.midPoint = {}
  return self
end