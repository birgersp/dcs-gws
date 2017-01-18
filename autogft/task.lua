---
-- @module Task

---
-- @type autogft_Task
-- @field #number type
-- @field #string zoneName
-- @field #boolean cleared
-- @field #boolean useRoads
-- @field #number speed
autogft_Task = {}

---
-- @param #autogft_Task self
-- @param #string zoneName
-- @param #number type
-- @return #autogft_Task
function autogft_Task:new(zoneName, type)
  autogft_assertZoneExists(zoneName)
  self = setmetatable({}, {__index = autogft_Task})
  self.zoneName = zoneName
  self.type = type
  self.cleared = false
  self.useRoads = false
  self.speed = 100
  return self
end

---
-- Defines various task types for task forces to complete.
-- @type autogft_taskTypes
-- @field #number CONTROL Clear a zone of enemy units, and retreat to it if enemies re-appear.
-- @field #number INTERMIDIATE Clear a zone of enemy units once, and move through it when advancing towards the next task.
autogft_taskTypes = {
  CONTROL = 1,
  INTERMIDIATE = 2
}
