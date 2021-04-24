---
-- @module Waypoint

---
-- @type Waypoint
-- @extends vector2#Vector2
-- @field #number speed
-- @field #string action
-- @field #string type
gws_Waypoint = gws_Vector2:extend()

---
-- @param #Waypoint self
-- @param #number x
-- @param #number y
-- @param #Waypoint.Action action (Optional)
-- @return #Waypoint
function gws_Waypoint:new(x, y, action)
  local roundedX = math.floor(x + 0.5)
  local roundedY = math.floor(y + 0.5)
  self = self:createInstance(gws_Vector2:new(roundedX, roundedY))
  self.speed = 100
  if action then
    self.action = action
  else
    self.action = gws_Waypoint.Action.CONE
  end
  self.type = gws_Waypoint.Type.TURNING_POINT
  return self
end

---
-- @type Waypoint.Action
-- @field #string CONE
-- @field #string OFF_ROAD
-- @field #string ON_ROAD
gws_Waypoint.Action = {
  CONE = "Cone",
  OFF_ROAD = "Off Road",
  ON_ROAD = "On Road"
}

---
-- @type Waypoint.Type
-- @field #string TURNING_POINT
gws_Waypoint.Type = {
  TURNING_POINT = "Turning Point"
}
