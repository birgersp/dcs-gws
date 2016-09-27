-- Script used for mission development
-- Before mission deployment, remember to add the scripts to the mission
--devInitialized = false
if (devInitialized == nil or devInitialized == false) then
  assert(loadfile([[C:\Users\birge\Workspace\mission1\start.lua]]))()
  devInitialized = true
  initialized = false
end

assert(loadfile([[C:\Users\birge\Workspace\mission1\run.lua]]))()
