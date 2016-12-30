---
-- @module controlzone

---
-- @type autogft_ControlZone
-- @field #string name
-- @field #number status
autogft_ControlZone = {}

---
-- @param #autogft_ControlZone self
-- @param #string name
-- @return #autogft_ControlZone
function autogft_ControlZone:new(name)
  self = setmetatable({}, {__index = autogft_ControlZone})
  self.name = name
  self.status = coalition.side.NEUTRAL
  return self
end
