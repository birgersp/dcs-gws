
package.path = package.path .. ";../gws/?.lua"
require("util")

local obj1 = {}
local obj2 = {}

obj1.sibling = obj2
obj2.sibling = obj1
gws.log(obj1)

local myTable = {}
gws.log(gws.getTableID(myTable))
