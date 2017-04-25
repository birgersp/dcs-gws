
package.path = package.path .. ";../autogft/?.lua"
require("util")

local obj1 = {}
local obj2 = {}

obj1.sibling = obj2
obj2.sibling = obj1
autogft.log(obj1)

local myTable = {}
autogft.log(autogft.getTableID(myTable))
