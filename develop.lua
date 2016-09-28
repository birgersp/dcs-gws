-- Script used for mission development
-- Before mission deployment, remember to add the scripts to the mission
-- devInitialized = false
if (devInitialized == nil or devInitialized == false) then
  assert(loadfile([[C:\Users\birge\Workspace\dcs-bajas\bajas.lua]]))()
  assert(loadfile([[C:\Users\birge\Workspace\dcs-bajas\examples\mission1.lua]]))()
  
  devInitialized = true
  initialized = false
end
