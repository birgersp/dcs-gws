---
-- @type autogft_UnitCluster
-- @field #list<#string> unitNames
-- @field DCSTypes#Vec2 midPoint
autogft_UnitCluster = {}
autogft_UnitCluster.__index = autogft_UnitCluster

---
-- @param #autogft_UnitCluster self
-- @return #autogft_UnitCluster
function autogft_UnitCluster:new()
  local self = setmetatable({}, autogft_UnitCluster)
  self.unitNames = {}
  self.midPoint = {}
  return self
end