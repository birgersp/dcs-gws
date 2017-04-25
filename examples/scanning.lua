
--- 
-- "Scanning units" example
-- This will assume control of units, even if they are not located in the base, by scanning for group names starting with "TaskForce".
-- Note this task force doesn't have a base zone, so it will not be reinforced.

autogft_TaskForce:new()
  :addControlZone("CONTROL1")
  :addControlZone("CONTROL2")
  :addControlZone("CONTROL5")
  :scanUnits("TaskForce")
  