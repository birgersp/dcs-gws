-- Script used for mission development
-- Before mission deployment, remember to add the scripts to the mission
-- devInitialized = false
if (devInitialized == nil or devInitialized == false) then
    require("start")
    devInitialized = true
else
    require("run")
end