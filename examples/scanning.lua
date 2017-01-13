
--- 
-- "Scanning units" example
-- This will assume control of units, even if they are not located in the base, by scanning for group names starting with "TaskForce".
-- The task force will respawn in the base, as usual.

autogft_TaskForce:new()
  :addBaseZone("BLUE_BASE1")
  :addControlZone("CONTROL1")
  :addControlZone("CONTROL2")
  :addControlZone("CONTROL5")
  :scanUnits("TaskForce")