---
-- @module Waypoint

---
-- @type Waypoint
-- @extends class#Class
-- @field #number x
-- @field #number y
-- @field #number speed
-- @field #string action
-- @field #string type
autogft_Waypoint = autogft_Class:new()

---
-- @param #Waypoint self
-- @return #Waypoint
function autogft_Waypoint:new(x, y)
  self = self:createInstance()
  self.x = x
  self.y = y
  self.speed = 100
  self.action = autogft_Waypoint.Action.CONE
  self.type = autogft_Waypoint.Type.TURNING_POINT
  return self
end

---
-- @type Waypoint.Action
-- @field #string CONE
-- @field #string OFF_ROAD
-- @field #string ON_ROAD
autogft_Waypoint.Action = {
  CONE = "Cone",
  OFF_ROAD = "Off Road",
  ON_ROAD = "On Road"
}

---
-- @type Waypoint.Type
-- @field #string TURNING_POINT
autogft_Waypoint.Type = {
  TURNING_POINT = "Turning Point"
}
