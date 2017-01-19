---
-- @module UnitCluster

---
-- @type UnitCluster
-- @field #list<#string> unitNames
-- @field DCSTypes#Vec2 midPoint
autogft_UnitCluster = {}

---
-- @param #UnitCluster self
-- @return #UnitCluster
function autogft_UnitCluster:new()
  local self = setmetatable({}, {__index = autogft_UnitCluster})
  self.unitNames = {}
  self.midPoint = {}
  return self
end