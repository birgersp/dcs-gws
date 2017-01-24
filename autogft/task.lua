---
-- @module Task

---
-- @type Task
-- @extends class#Class
-- @field #boolean accomplished
-- @field #boolean useRoads
-- @field #number speed
autogft_Task = autogft_Class:create()

---
-- @param #Task self
-- @return #Task
function autogft_Task:new()
  self = self:createInstance()
  self.accomplished = false
  self.useRoads = false
  self.speed = 100
  return self
end

---
-- @param #Task self
-- @return #boolean
function autogft_Task:isAccomplished()
  return self.accomplished
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

---
-- @type CaptureTask
-- @extends #ZoneTask
-- @field #number coalition
autogft_CaptureTask = autogft_ZoneTask:extend()

---
-- @param #CaptureTask self
-- @param #string zoneName
-- @param #number coalition
-- @return #CaptureTask
function autogft_CaptureTask:new(zoneName, coalition)
  self = self:createInstance(autogft_ZoneTask:new(zoneName))
  self.coalition = coalition
  return self
end

---
-- @param #CaptureTask self
-- @param #number coalitionID
-- @return #boolean
function autogft_CaptureTask:hasUnitPresent(coalitionID)
  local radiusSquared = self.zone.radius^2
  local result = false
  local groups = coalition.getGroups(coalitionID)
  local groupIndex = 1
  while not result and groupIndex <= #groups do
    local units = groups[groupIndex]:getUnits()
    local unitIndex = 1
    while not result and unitIndex <= #units do
      local unit = units[unitIndex]
      local pos = unit:getPosition().p
      local dx = self.zone.point.x - pos.x
      local dy = self.zone.point.z - pos.z
      if (dx*dx + dy*dy) <= radiusSquared then
        result = true
      end
      unitIndex = unitIndex + 1
    end
    groupIndex = groupIndex + 1
  end
  return result
end

---
-- @param #CaptureTask self
-- @return #boolean
function autogft_CaptureTask:hasFriendlyPresent()
  return self:hasUnitPresent(self.coalition)
end

---
-- @param #CaptureTask self
-- @return #boolean
function autogft_CaptureTask:hasEnemyPresent()
  local enemyCoalition
  if self.coalition == coalition.side.BLUE then
    enemyCoalition = coalition.side.RED
  else
    enemyCoalition = coalition.side.BLUE
  end
  return self:hasUnitPresent(enemyCoalition)
end

---
-- @param #CaptureTask self
-- @return #boolean
function autogft_CaptureTask:isAccomplished()
  if not autogft_Task.isAccomplished(self) then
    if self:hasFriendlyPresent() and not self:hasEnemyPresent() then
        self.accomplished = true
    end
  end
  return autogft_Task.isAccomplished(self)
end

---
-- @type ControlTask
-- @extends #CaptureTask
autogft_ControlTask = autogft_CaptureTask:extend()

---
-- @param #ControlTask self
-- @return #boolean
function autogft_ControlTask:isAccomplished()
  self.accomplished = self:hasFriendlyPresent() and not self:hasEnemyPresent()
  return autogft_Task.isAccomplished(self)
end
