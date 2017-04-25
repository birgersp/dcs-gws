
package.path = package.path .. ";../autogft/?.lua"
require("core")

local obj1 = {}
local obj2 = {}

obj1.sibling = obj2
obj2.sibling = obj1
autogft.log(obj1)
