---
-- @module Coordinate

---
-- @type Coordinate
-- @extends class#Class
-- @field #number degrees
-- @field #number minutes
gws_Coordinate = gws_Class:create()

---
-- @param #Coordinate self
-- @param #number degrees
-- @return #Coordinate
function gws_Coordinate:new(degrees)
  self = self:createInstance()

  self.degrees = math.floor(degrees)
  self.minutes = (degrees - self.degrees) * 60

  return self
end

---
-- @param #Coordinate self
-- @param #number minDigits
-- @return #string
function gws_Coordinate:getDegreesString(minDigits)
  local string = self.degrees .. ""
  if minDigits then
    while string:len() < minDigits do
      string = "0" .. string
    end
  end
  return string
end

---
-- @param #Coordinate self
-- @param #number minDecimals
-- @param #number maxDecimals
-- @return #string
function gws_Coordinate:getMinutesString(minDecimals, maxDecimals)

  local whole = math.floor(self.minutes)
  local wholeString = whole .. ""
  while wholeString:len() < 2 do
    wholeString = "0" .. wholeString
  end

  local minutesString = self.minutes .. ""
  local fracString = ""

  local dotIndex = minutesString:find("%.")
  if dotIndex ~= nil then
    fracString = minutesString:sub(dotIndex + 1, -1)
  end

  if maxDecimals and fracString:len() > maxDecimals then
    fracString = fracString:sub(0, maxDecimals)
  elseif minDecimals then
    while fracString:len() < minDecimals do
      fracString = fracString .. "0"
    end
  end

  return wholeString .. "." .. fracString
end
