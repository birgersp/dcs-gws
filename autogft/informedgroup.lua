---
-- @module InformedGroup

---
-- @type InformedGroup
-- @extends class#Class
-- @field DCSGroup#Group targetGroup
-- @field #number groupID
-- @field #number coalitionID
autogft_InformedGroup = autogft_Class:create()

autogft_InformedGroup.TARGET_COMMAND_TEXT = "TARGET"
autogft_InformedGroup.MESSAGE_TIME = 60

---
-- @param #InformedGroup self
-- @param DCSGroup#Group targetGroup
-- @return #InformedGroup
function autogft_InformedGroup:new(targetGroup)
  self = self:createInstance()
  self.targetGroup = targetGroup
  self.groupID = targetGroup:getID()
  self.coalitionID = targetGroup:getCoalition()

  local function viewTarget()
    self:viewTarget()
  end

  autogft_GroupCommand:new(targetGroup, autogft_InformedGroup.TARGET_COMMAND_TEXT, viewTarget):enable()

  return self
end

---
-- @param #InformedGroup self
function autogft_InformedGroup:viewTarget()

  trigger.action.outTextForGroup(self.groupID, autogft_intel.intelMessage[self.coalitionID], autogft_InformedGroup.MESSAGE_TIME)
end