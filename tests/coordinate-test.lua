
package.path = package.path .. ";../autogft/?.lua"
require("class")
require("coordinate")

local coordinate1 = autogft_Coordinate:new(12.3456)
assert(coordinate1.degrees == 12)
assert(coordinate1.minutes .. "" == "20.736")

local coordinate2 = autogft_Coordinate:new(12.3456789, 4)
assert(coordinate2.degrees == 12)
assert(coordinate2.minutes .. "" == "20.7407")
