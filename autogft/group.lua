---
-- @module group

---
-- @type autogft_TaskForceGroup
-- @field #list<unitspec#autogft_UnitSpec> unitSpecs
-- @field taskforce#autogft_TaskForce taskForce
-- @field DCSGroup#Group dcsGroup
-- @field #number destination
autogft_TaskForceGroup = {}

---
-- @param #autogft_TaskForceGroup self
-- @param taskforce#autogft_TaskForce taskForce
-- @return #autogft_TaskForceGroup
function autogft_TaskForceGroup:new(taskForce)
  self = setmetatable({}, {__index = autogft_TaskForceGroup})
  self.unitSpecs = {}
  self.taskForce = taskForce
  self:setDCSGroup(nil)
  return self
end

---
-- @param #autogft_TaskForceGroup self
-- @return #autogft_TaskForceGroup
function autogft_TaskForceGroup:updateDestination()

  if self.dcsGroup then
    local units = self.dcsGroup:getUnits()
    if #units > 0 then
      -- Get group lead
      local groupLead
      local unitIndex = 1
      while unitIndex <= #units and not groupLead do
        if units[unitIndex]:isExist() then groupLead = units[unitIndex] end
      end

      -- Check location of group lead
      if groupLead then
        local destinationZone = trigger.misc.getZone(self.taskForce.tasks[self.destination].zoneName)
        if autogft_unitIsWithinZone(groupLead, destinationZone) then
          -- If destination reached, update target
          if self.destination < self.taskForce.target then
            self.destination = self.destination + 1
          elseif self.destination > self.taskForce.target then
            self.destination = self.destination - 1
          end
        end
      end
    end
  end
  return self
end

---
-- @param #autogft_TaskForceGroup self
-- @return #autogft_TaskForceGroup
function autogft_TaskForceGroup:exists()
  if self.dcsGroup then
    local units = self.dcsGroup:getUnits()
    if #units > 0 then
      for unitIndex = 1, #units do
        if units[unitIndex]:isExist() then return true end
      end
    end
  end
  self.dcsGroup = nil
  return false
end

---
-- @param #autogft_TaskForceGroup self
-- @param DCSUnit#Unit unit
-- @return #boolean
function autogft_TaskForceGroup:containsUnit(unit)
  if self.dcsGroup then
    local units = self.dcsGroup:getUnits()
    for unitIndex = 1, #units do
      if units[unitIndex]:getID() == unit:getID() then return true end
    end
  end
  return false
end

---
-- @param #autogft_TaskForceGroup self
-- @param unitspec#autogft_UnitSpec unitSpec
function autogft_TaskForceGroup:addUnitSpec(unitSpec)
  self.unitSpecs[#self.unitSpecs + 1] = unitSpec
  return self
end

---
-- @param #autogft_TaskForceGroup self
-- @return #autogft_TaskForceGroup
function autogft_TaskForceGroup:advance()
  if self:exists() then
    self:updateDestination()

    local targetTask = self.taskForce.tasks[self.destination]

    local destinationZone = trigger.misc.getZone(self.taskForce.tasks[self.destination].zoneName)
    local destinationZonePos2 = {
      x = destinationZone.point.x,
      y = destinationZone.point.z
    }
    local radius = destinationZone.radius

    -- If the task force has a "max distance" specified
    if self.taskForce.maxDistanceKM > 0 then
      local units = self.dcsGroup:getUnits()
      local unitIndex = 1
      local groupLeader
      while not groupLeader and unitIndex <= #units do
        if units[unitIndex]:isExist() then
          groupLeader = units[unitIndex]
        else
          unitIndex = unitIndex + 1
        end
      end
      if not groupLeader then return self end
      local groupPos = groupLeader:getPosition().p
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

    local randomPointVars = {
      group = self.dcsGroup,
      point = destinationZonePos2,
      radius = radius,
      speed = targetTask.speed,
      formation = self.taskForce.formation,
      disableRoads = not targetTask.useRoads
    }
    mist.groupToRandomPoint(randomPointVars)
  end

  return self
end

---
-- @param #autogft_TaskForceGroup self
-- @param DCSGroup#Group newGroup
-- @return #autogft_TaskForceGroup
function autogft_TaskForceGroup:setDCSGroup(newGroup)
  self.dcsGroup = newGroup
  self.destination = 1
  return self
end
