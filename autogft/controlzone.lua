---
-- @module ControlZone

---
-- @type ControlZone
-- @extends class#Class
-- @field #string name
-- @field #number status
autogft_ControlZone = autogft_Class:create()

---
-- @param #ControlZone self
-- @param #string name
-- @return #ControlZone
function autogft_ControlZone:new(name)
  self = self:createInstance()
  self.name = name
  self.status = coalition.side.NEUTRAL
  return self
end
