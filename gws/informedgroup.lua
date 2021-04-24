---
-- @module InformedGroup

---
-- @type InformedGroup
-- @extends class#Class
-- @field DCSGroup#Group targetGroup
-- @field #number groupID
-- @field #number coalitionID
gws_InformedGroup = gws_Class:create()

gws_InformedGroup.TARGET_COMMAND_TEXT = "TARGET"
gws_InformedGroup.MESSAGE_TIME = 60

---
-- @param #InformedGroup self
-- @param DCSGroup#Group targetGroup
-- @return #InformedGroup
function gws_InformedGroup:new(targetGroup)
  self = self:createInstance()
  self.targetGroup = targetGroup
  self.groupID = targetGroup:getID()
  self.coalitionID = targetGroup:getCoalition()

  local function viewTarget()
    self:viewTarget()
  end

  gws_GroupCommand:new(targetGroup, gws_InformedGroup.TARGET_COMMAND_TEXT, viewTarget):enable()

  return self
end

---
-- @param #InformedGroup self
function gws_InformedGroup:viewTarget()

  trigger.action.outTextForGroup(self.groupID, gws_intel.intelMessage[self.coalitionID], gws_InformedGroup.MESSAGE_TIME)
end