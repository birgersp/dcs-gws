---
-- @module Coordinate

---
-- @type Coordinate
-- @extends class#Class
-- @field #number degrees
-- @field #number minutes
autogft_Coordinate = autogft_Class:create()

---
-- @param #Coordinate self
-- @param #number degrees
-- @param #number minuteDecimals
-- @return #Coordinate
function autogft_Coordinate:new(degrees, minuteDecimals)
  self = self:createInstance()

  self.degrees = math.floor(degrees)
  self.minutes = (degrees - self.degrees) * 60

  if minuteDecimals then
    local factor = 10^minuteDecimals
    self.minutes = math.floor(self.minutes * factor) / factor
  end

  return self
end
