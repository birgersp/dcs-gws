-- Script used for mission development
-- Before mission deployment, remember to add the scripts to the mission
-- devInitialized = false
if (devInitialized == nil or devInitialized == false) then
  assert(loadfile([[C:\Users\birge\Workspace\mission1\bsputil.lua]]))()
  assert(loadfile([[C:\Users\birge\Workspace\mission1\mission1.lua]]))()
  
  devInitialized = true
  initialized = false
end
