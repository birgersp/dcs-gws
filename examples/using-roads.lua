
--- 
-- Using roads example
-- This task force will use roads when advanding between certain tasks

autogft_TaskForce:new()
  :addBaseZone("BLUE_BASE2")
  :addControlZone("CONTROL1")
  :startUsingRoads() -- (use roads to get to CONTROL2 and CONTROL5)
  :addControlZone("CONTROL2")
  :addControlZone("CONTROL5")
  :stopUsingRoads() -- (don't use roads to get to CONTROL3)
  :addControlZone("CONTROL3")
