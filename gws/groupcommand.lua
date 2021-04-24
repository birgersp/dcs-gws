---
-- @module GroupCommand

---
-- @type GroupCommand
-- @extends class#Class
-- @field #string commandText
-- @field #number groupId
-- @field #function func
-- @field #number timerId
-- @field #boolean enabled
autogft_GroupCommand = autogft_Class:create()

autogft_GroupCommand.COMMAND_COUNT = 0

---
-- @param #GroupCommand self
-- @param DCSGroup#Group group
-- @param #string commandText
-- @param #function func
-- @return #GroupCommand
function autogft_GroupCommand:new(group, commandText, func)
  self = self:createInstance()
  self.commandText = commandText
  self.groupId = group:getID()
  self.func = func
  return self
end

---
-- @param #GroupCommand self
function autogft_GroupCommand:enable()
  self.enabled = true

  local flagName = "groupCommandFlag"..autogft_GroupCommand.COMMAND_COUNT
  autogft_GroupCommand.COMMAND_COUNT = autogft_GroupCommand.COMMAND_COUNT + 1

  trigger.action.setUserFlag(flagName, 0)
  trigger.action.addOtherCommandForGroup(self.groupId, self.commandText, flagName, 1)

  local function checkTrigger()
    if self.enabled == true then
      if (trigger.misc.getUserFlag(flagName) == 1) then
        trigger.action.setUserFlag(flagName, 0)
        self.func()
      end
      autogft.scheduleFunction(checkTrigger, 1)
    else
    end
  end
  checkTrigger()
end

---
-- @param #GroupCommand self
function autogft_GroupCommand:disable()
  -- Remove group command from mission
  trigger.action.removeOtherCommandForGroup(self.groupId, self.commandText)
  self.enabled = false
end
