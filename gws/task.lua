---
-- @module Task

---
-- @type Task
-- @extends class#Class
-- @field #boolean accomplished
-- @field #boolean useRoads
-- @field #number speed
gws_Task = gws_Class:create()

---
-- @param #Task self
-- @return #Task
function gws_Task:new()
  self = self:createInstance()
  self.accomplished = false
  self.useRoads = false
  self.speed = 100
  return self
end

---
-- @param #Task self
-- @return #boolean
function gws_Task:isAccomplished()
  return self.accomplished
end

---
-- @param #Task self
-- @return vector2#Vector2
function gws_Task:getLocation()
  self:throwAbstractFunctionError()
end

---
-- @type ZoneTask
-- @extends #Task
-- @field DCSZone#Zone zone
gws_ZoneTask = gws_Task:extend()

---
-- @param #ZoneTask self
-- @return #ZoneTask
function gws_ZoneTask:new(zoneName)
  self = self:createInstance()
  self.zone = trigger.misc.getZone(zoneName)
  assert(self.zone, "Zone \"" .. zoneName .. "\" does not exist in this mission.")
  return self
end

---
-- @param #ZoneTask self
-- @return vector2#Vector2
function gws_ZoneTask:getLocation()
  local radius = self.zone.radius
  local zonePos = gws_Vector2:new(self.zone.point.x, self.zone.point.z)
  local randomAngle = math.random(math.pi * 2)
  local randomPos = gws_Vector2:new(math.cos(randomAngle), math.sin(randomAngle)):scale(radius * 0.75)
  return zonePos:plus(randomPos)
end

---
-- @type CaptureTask
-- @extends #ZoneTask
-- @field #number coalition
gws_CaptureTask = gws_ZoneTask:extend()

---
-- @param #CaptureTask self
-- @param #string zoneName
-- @param #number coalition
-- @return #CaptureTask
function gws_CaptureTask:new(zoneName, coalition)
  self = self:createInstance(gws_ZoneTask:new(zoneName))
  self.coalition = coalition
  return self
end

---
-- @param #CaptureTask self
-- @param #number coalitionID
-- @return #boolean
function gws_CaptureTask:hasUnitPresent(coalitionID)
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
function gws_CaptureTask:hasFriendlyPresent()
  return self:hasUnitPresent(self.coalition)
end

---
-- @param #CaptureTask self
-- @return #boolean
function gws_CaptureTask:hasEnemyPresent()
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
function gws_CaptureTask:isAccomplished()
  if not gws_Task.isAccomplished(self) then
    if self:hasFriendlyPresent() and not self:hasEnemyPresent() then
      self.accomplished = true
    end
  end
  return gws_Task.isAccomplished(self)
end

---
-- @type ControlTask
-- @extends #CaptureTask
gws_ControlTask = gws_CaptureTask:extend()

---
-- @param #ControlTask self
-- @return #boolean
function gws_ControlTask:isAccomplished()
  if self:hasEnemyPresent() then
    self.accomplished = false
  elseif not self.accomplished then
    self.accomplished = self:hasFriendlyPresent()
  end
  return gws_Task.isAccomplished(self)
end
