---
-- @module Task

---
-- @type Task
-- @extends class#Class
-- @field #boolean cleared
-- @field #boolean useRoads
-- @field #number speed
autogft_Task = autogft_Class:create()

---
-- @param #Task self
-- @return #Task
function autogft_Task:new()
  self = self:createInstance()
  self.cleared = false
  self.useRoads = false
  self.speed = 100
  return self
end

---
-- @type ZoneTask
-- @extends #Task
-- @field DCSZone#Zone zone
autogft_ZoneTask = autogft_Task:extend()

---
-- @param #ZoneTask self
-- @return #ZoneTask
function autogft_ZoneTask:new(zoneName)
  self = self:createInstance()
  autogft.assertZoneExists(zoneName)
  self.zone = trigger.misc.getZone(zoneName)
  return self
end