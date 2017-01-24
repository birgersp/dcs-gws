---
-- @module Group

---
-- @type Group
-- @extends class#Class
-- @field #list<unitspec#UnitSpec> unitSpecs
-- @field taskforce#TaskForce taskForce
-- @field DCSGroup#Group dcsGroup
-- @field DCSUnit#Unit groupLead
-- @field #number destination
-- @field #boolean progressing
autogft_Group = autogft_Class:create()

---
-- @param #Group self
-- @param taskforce#TaskForce taskForce
-- @return #Group
function autogft_Group:new(taskForce)
  self = self:createInstance()
  self.unitSpecs = {}
  self.taskForce = taskForce
  self.progressing = true
  self:setDCSGroup(nil)
  return self
end

---
-- @param #Group self
function autogft_Group:updateGroupLead()
  autogft.debugFunction()
  self.groupLead = nil
  if self.dcsGroup then
    local unitIndex = 1
    local units = self.dcsGroup:getUnits()
    while unitIndex <= #units and not self.groupLead do
      if units[unitIndex]:isExist() then self.groupLead = units[unitIndex] end
      unitIndex = unitIndex + 1
    end
    if not self.dcsGroup then
      self.dcsGroup = nil
    end
  end
end

---
-- @param #Group self
-- @return #Group
function autogft_Group:exists()
  self:updateGroupLead()
  if self.groupLead then
    return true
  end
  return false
end

---
-- @param #Group self
-- @param DCSUnit#Unit unit
-- @return #boolean
function autogft_Group:containsUnit(unit)
  if self.dcsGroup then
    local units = self.dcsGroup:getUnits()
    for unitIndex = 1, #units do
      if units[unitIndex]:getID() == unit:getID() then return true end
    end
  end
  return false
end

---
-- @param #Group self
-- @param unitspec#UnitSpec unitSpec
function autogft_Group:addUnitSpec(unitSpec)
  self.unitSpecs[#self.unitSpecs + 1] = unitSpec
  return self
end

---
-- @param #Group self
-- @return #Group
function autogft_Group:advance()

  self:updateGroupLead()
  if self.groupLead then

    -- Check location of group lead
    local destinationZone = self.taskForce.tasks[self.destination].zone
    if autogft.unitIsWithinZone(self.groupLead, destinationZone) then
      -- If destination reached, update target
      if self.destination < self.taskForce.target then
        self.destination = self.destination + 1
        self.progressing = true
      elseif self.destination > self.taskForce.target then
        self.destination = self.destination - 1
        self.progressing = false
      end
    end

    local destinationTask = self.taskForce.tasks[self.destination]

    local destinationZone = self.taskForce.tasks[self.destination].zone
    local destinationZonePos2 = {
      x = destinationZone.point.x,
      y = destinationZone.point.z
    }
    local radius = destinationZone.radius

    -- If the task force has a "max distance" specified
    if self.taskForce.maxDistanceKM > 0 then
      local units = self.dcsGroup:getUnits()
      local groupPos = self.groupLead:getPosition().p
      local groupToZone = {
        x = destinationZone.point.x - groupPos.x,
        z = destinationZone.point.z - groupPos.z
      }
      local groupToZoneMag = math.sqrt(groupToZone.x^2 + groupToZone.z^2)
      local maxDistanceM = self.taskForce.maxDistanceKM * 1000
      if groupToZoneMag - destinationZone.radius > maxDistanceM then
        destinationZonePos2.x = groupPos.x + groupToZone.x / groupToZoneMag * maxDistanceM
        destinationZonePos2.y = groupPos.z + groupToZone.z / groupToZoneMag * maxDistanceM
        radius = 0
      end
    end

    -- (Whether to use roads or not, depends on the next task)
    local nextTask = destinationTask
    if not self.progressing then
      nextTask = self.taskForce.tasks[self.destination + 1]
    end

    local randomPointVars = {
      group = self.dcsGroup,
      point = destinationZonePos2,
      radius = radius,
      speed = nextTask.speed,
      formation = self.taskForce.formation,
      disableRoads = not nextTask.useRoads
    }

    mist.groupToRandomPoint(randomPointVars)
  end

  return self
end

---
-- @param #Group self
-- @param DCSGroup#Group newGroup
-- @return #Group
function autogft_Group:setDCSGroup(newGroup)
  self.dcsGroup = newGroup
  self.destination = 1
  return self
end

---
-- @param #Group self
-- @param #list<waypoint#Waypoint> waypoints
function autogft_Group:setRoute(waypoints)
  if self:exists() then
    local dcsTask = {
      id = "Mission",
      params = {
        route = {
          points = waypoints
        }
      }
    }
    self.dcsGroup:getController():setTask(dcsTask)
  end
end
