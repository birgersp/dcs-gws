
package.path = package.path .. ";../autogft/?.lua"
require("class")
require("util")
require("map")

local someKey = {}
local someValue = {x = 123}

local map = autogft_Map:new()
map:put(someKey, someValue)

local someOtherKey = {}
assert(map:get(someOtherKey) == nil)
assert(map:get(someKey).x == 123)
