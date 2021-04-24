---
-- @module Map

---
-- @type Map
-- @extends class#Class
-- @field #map<#number, #table> keys
-- @field #map<#number, #table> values
-- @field #number length
gws_Map = gws_Class:create()

---
-- @param #Map self
-- @return #Map
function gws_Map:new()
  self = self:createInstance()
  self.keys = {}
  self.values = {}
  self.length = 0
  return self
end

---
-- @param #Map self
-- @param #table key
-- @param #table value
function gws_Map:put(key, value)
  local id = gws.getTableID(key)
  if not self.keys[id] then
    self.keys[id] = key
    self.length = self.length + 1
  end
  self.values[id] = value
end

---
-- @param #Map self
-- @param #table key
-- @return #table
function gws_Map:get(key)
  local id = gws.getTableID(key)
  return self.values[id]
end
