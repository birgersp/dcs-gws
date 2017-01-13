
autogft_TaskForce:new()
  :addBaseZone("BLUE_BASE2")
  :addControlZone("CONTROL1")
  :setUseRoads(true) -- (use roads to get to CONTROL2)
  :addControlZone("CONTROL2")
  :setUseRoads(false) -- (don't use roads to get to CONTROL3)
  :addControlZone("CONTROL3")
