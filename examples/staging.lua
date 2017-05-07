
--- 
-- Reinforcing from idle units (staging) example
-- The desired groups and units must be specified. In this example, 2 groups are specified with 2 units in each
-- The "reinforce timer" will disable automatic respawning, and the task force will be reinforced from idle units instead (time interval: 600 seconds)

autogft_Setup:new()
  :useStaging()
  :addGroup():addUnits(2,"M-1 Abrams")
  :addGroup():addUnits(2,"M-1 Abrams")
  :addBaseZone("BLUE_BASE3")
  :addControlZone("CONTROL1")
  :addControlZone("CONTROL2")
  :addControlZone("CONTROL3")
  :setReinforceTimer(600)
