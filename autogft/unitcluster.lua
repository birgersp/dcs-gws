---
-- @module autogft_UnitCluster

---
-- @type autogft_UnitCluster
-- @field #list<#string> unitNames
-- @field DCSTypes#Vec2 midPoint
autogft_UnitCluster = {}

---
-- @param #autogft_UnitCluster self
-- @return #autogft_UnitCluster
function autogft_UnitCluster:new()
  local self = setmetatable({}, {__index = autogft_UnitCluster})
  self.unitNames = {}
  self.midPoint = {}
  return self
end