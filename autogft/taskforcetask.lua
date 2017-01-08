---
-- @module taskforcetask

---
-- @type autogft_TaskForceTask
-- @field #number type
-- @field #string zoneName
-- @field #boolean cleared
autogft_TaskForceTask = {}

---
-- @param #autogft_TaskForceTask self
-- @param #string zoneName
-- @param #number type
-- @return #autogft_TaskForceTask
function autogft_TaskForceTask:new(zoneName, type)
  autogft_assertZoneExists(zoneName)
  self = setmetatable({}, {__index = autogft_TaskForceTask})
  self.zoneName = zoneName
  self.type = type
  self.cleared = false
  return self
end

---
-- Defines various task types for task forces to complete.
-- @type autogft_taskTypes
-- @field #number CAPTURE Clear a zone of enemy units once.
-- @field #number CONTROL Clear a zone of enemy units, and retreat to it if enemies re-appear.
-- @field #number INTERMIDIATE Move through a zone when advancing through the tasks.
autogft_taskTypes = {
  CAPTURE = 0,
  CONTROL = 1,
  INTERMIDIATE = 2
}
