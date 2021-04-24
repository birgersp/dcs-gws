
package.path = package.path .. ";../gws/?.lua"
require("class")
require("util")
require("map")

local someKey = {}
local someValue = {x = 123}

local map = gws_Map:new()
assert(map.length == 0)
map:put(someKey, someValue)

local someOtherKey = {}
assert(map:get(someOtherKey) == nil)
assert(map:get(someKey).x == 123)
assert(map.length == 1)

map:put(someKey, 1337)
assert(map.length == 1)
