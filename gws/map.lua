---
-- @module Map

---
-- @type Map
-- @extends class#Class
-- @field #map<#number, #table> keys
-- @field #map<#number, #table> values
-- @field #number length
autogft_Map = autogft_Class:create()

---
-- @param #Map self
-- @return #Map
function autogft_Map:new()
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
function autogft_Map:put(key, value)
  local id = autogft.getTableID(key)
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
function autogft_Map:get(key)
  local id = autogft.getTableID(key)
  return self.values[id]
end
