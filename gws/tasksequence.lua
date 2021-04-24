---
-- @module TaskSequence

---
-- @type TaskSequence
-- @extends class#Class
-- @field #list<task#Task> tasks
-- @field #number currentTaskIndex
autogft_TaskSequence = autogft_Class:create()

---
-- @param #TaskSequence self
-- @return #TaskSequence
function autogft_TaskSequence:new()
  self = self:createInstance()
  self.tasks = {}
  self.currentTaskIndex = 0
  return self
end

---
-- @param #TaskSequence self
-- @param task#Task task
function autogft_TaskSequence:addTask(task)
  self.tasks[#self.tasks + 1] = task
end

---
-- @param #TaskSequence self
function autogft_TaskSequence:updateCurrentTask()
  local newTaskIndex
  local taskIndex = 1
  while not newTaskIndex and taskIndex <= #self.tasks do
    if not self.tasks[taskIndex]:isAccomplished() then
      newTaskIndex = taskIndex
    end
    taskIndex = taskIndex + 1
  end
  if not newTaskIndex then
    newTaskIndex = #self.tasks
  end
  self.currentTaskIndex = newTaskIndex
end

---
-- @param #TaskSequence self
function autogft_TaskSequence:getCurrentTask()
  return self.tasks[self.currentTaskIndex]
end
