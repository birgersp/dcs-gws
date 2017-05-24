---
-- @module GroupIntel

---
-- @type GroupIntel
-- @extends class#Class
-- @field DCSGroup#Group targetGroup
-- @field groupcommand#GroupCommand startCommand
-- @field groupcommand#GroupCommand stopCommand
-- @field #boolean started
autogft_GroupIntel = autogft_Class:create()

autogft_GroupIntel.START_COMMAND_TEXT = "START INTEL"
autogft_GroupIntel.STOP_COMMAND_TEXT = "STOP INTEL"
autogft_GroupIntel.INTEL_LOOP_DELAY = 60

---
-- @param #GroupIntel self
-- @param DCSGroup#Group targetGroup
-- @return #GroupIntel
function autogft_GroupIntel:new(targetGroup)

  self = self:createInstance()
  self.targetGroup = targetGroup
  self.started = false

  local function start()
    self:start()
  end
  self.startCommand = autogft_GroupCommand:new(targetGroup, autogft_GroupIntel.START_COMMAND_TEXT, start)
  self.startCommand:enable()

  local function stop()
    self:stop()
  end
  self.stopCommand = autogft_GroupCommand:new(targetGroup, autogft_GroupIntel.STOP_COMMAND_TEXT, stop)

  return self
end

---
-- @param #GroupIntel self
function autogft_GroupIntel:start()
  if self.started then
    do return end
  end

  self.started = true
  self.startCommand:disable()
  self.stopCommand:enable()

  local function intelLoop()
    if self.started then
      if self.targetGroup:isExist() then
        autogft_iocev.informOfClosestEnemyVehicles(self.targetGroup)
        autogft.scheduleFunction(intelLoop, autogft_GroupIntel.INTEL_LOOP_DELAY)
      else
        self:stop()
      end
    end
  end
  intelLoop()
end

---
-- @param #GroupIntel self
function autogft_GroupIntel:stop()
  self.started = false
  self.stopCommand:disable()
  self.startCommand:enable()
end
