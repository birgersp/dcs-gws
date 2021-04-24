
package.path = package.path .. ";../gws/?.lua"
require("class")
require("coordinate")

local coordinate1 = gws_Coordinate:new(12.3456)
assert(coordinate1.degrees == 12)
assert(coordinate1.minutes .. "" == "20.736")

assert(coordinate1:getDegreesString(3) == "012")
assert(coordinate1:getMinutesString(4) == "20.7360")
assert(coordinate1:getMinutesString(1, 2) == "20.73")
