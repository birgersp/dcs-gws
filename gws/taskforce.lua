---
-- @module TaskForce

---
-- @type TaskForce
-- @extends class#Class
-- @field tasksequence#TaskSequence taskSequence
-- @field reinforcer#Reinforcer reinforcer
-- @field #list<taskgroup#TaskGroup> groups
gws_TaskForce = gws_Class:create()

---
-- @param #TaskForce self
-- @return #TaskForce
function gws_TaskForce:new()
  self = self:createInstance()
  self.taskSequence = gws_TaskSequence:new()
  self.reinforcer = gws_RespawningReinforcer:new()
  self.groups = {}
  return self
end

---
-- @param #TaskForce self
function gws_TaskForce:updateTarget()
  self.taskSequence:updateCurrentTask()
end

---
-- @param #TaskForce self
function gws_TaskForce:advance()
  for i = 1, #self.groups do
    local group = self.groups[i]
    if group:exists() then group:advance() end
  end
end

---
-- @param #TaskForce self
-- @return #TaskForce
function gws_TaskForce:reinforce()
  if self.taskSequence.currentTaskIndex == 0 then
    self:updateTarget()
  end
  self.reinforcer:reinforce()
end
