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
-- @field #number ROUTE_OVERSHOOT
autogft_Group = autogft_Class:create()
autogft_Group.ROUTE_OVERSHOOT = 500

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

    local currentDestination = self.destination
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

    if currentDestination ~= self.destination then
      self:forceAdvance()
    else
      local prevPos = self.groupLead:getPosition().p
      local prevPosX = prevPos.x
      local prevPosZ = prevPos.z
      local function checkPosAdvance()
        if self.groupLead then
          local currentPos = self.groupLead:getPosition().p
          if currentPos.x == prevPosX and currentPos.z == prevPosZ then
            self:forceAdvance()
          end
        end
      end
      autogft.scheduleFunction(checkPosAdvance, 2)
    end
  end
end

---
-- @param #Group self
-- @return #Group
function autogft_Group:forceAdvance()

  local destination

  local destinationTask = self.taskForce.tasks[self.destination]
  local destinationZone = self.taskForce.tasks[self.destination].zone
  local destinationZonePos = autogft_Vector2:new(destinationZone.point.x, destinationZone.point.z)
  local groupLeadPosDCS = self.groupLead:getPosition().p
  local groupPos = autogft_Vector2:new(groupLeadPosDCS.x, groupLeadPosDCS.z)
  local groupToZone = destinationZonePos:minus(groupPos)
  local groupToZoneMag = groupToZone:getMagnitude()

  -- If the task force has a "max distance" specified
  if self.taskForce.maxDistanceKM > 0 then
    local units = self.dcsGroup:getUnits()

    local maxDistanceM = self.taskForce.maxDistanceKM * 1000
    if groupToZoneMag - destinationZone.radius > maxDistanceM then
      local destinationX = groupPos.x + groupToZone.x / groupToZoneMag * maxDistanceM
      local destinationY = groupPos.y + groupToZone.y / groupToZoneMag * maxDistanceM
      destination = autogft_Vector2:new(destinationX, destinationY)
    end
  end

  -- Determine if destination position is shortened
  local shortened = false
  if destination then
    shortened = true
  else
    -- If not shortened, use random point
    local radius = destinationZone.radius - autogft_Group.ROUTE_OVERSHOOT
    if radius < 0 then
      radius = 0
    end
    local randomAngle = math.random(math.pi * 2)
    local randomPos = autogft_Vector2:new(math.cos(randomAngle), math.sin(randomAngle)):scale(radius)
    destination = destinationZonePos:plus(randomPos)
  end

  -- (Whether to use roads or not, depends on the next task)
  local nextTask = destinationTask
  if not self.progressing then
    nextTask = self.taskForce.tasks[self.destination + 1]
  end
  local useRoads = nextTask.useRoads

  local waypoints = {}
  local function addWaypoint(x, y, useRoad)
    local wp = autogft_Waypoint:new(x, y)
    wp.speed = nextTask.speed
    if useRoad then
      wp.action = autogft_Waypoint.Action.ON_ROAD
    end
    waypoints[#waypoints + 1] = wp
  end

  addWaypoint(groupPos.x, groupPos.y)

  -- Only use roads if group is at a certain distance away from zone
  if useRoads and groupToZoneMag > (destinationZone.radius * 1.5) then
    addWaypoint(groupPos.x + 1, groupPos.y + 1, true)
    addWaypoint(destination.x, destination.y, true)
  end

  if not shortened then
    local overshoot = destination:plus(groupPos:times(-1)):normalize():scale(autogft_Group.ROUTE_OVERSHOOT):add(destination)
    addWaypoint(overshoot.x, overshoot.y)
  end

  if not shortened or not useRoads then
    addWaypoint(destination.x + 1, destination.y + 1, useRoads)
  end

  self:setRoute(waypoints)

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
