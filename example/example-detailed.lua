
-- (VARIOUS OTHER FEATURES EXAMPLE)
-- (Showing optional stuff you can do with a task force)
-- Another US task force;
-- manually specifying country, groups and units
-- using roads,
-- excellent skill,
-- max advancement distance 3km (route calculation),
-- low speed (5knots),
-- scanning units,
-- manually setting the advance timer to 600 second intervals,
-- manually setting the respawning timer to 300 second intervals, for a total of 1200 sec (20 min)

autogft_TaskForce:new()
  :setCountry(country.id.USA)
  :addUnits(4, "M-1 Abrams")
  :addBaseZone("BLUE_BASE")
  :addControlZone("CONTROL1")
  :setUseRoads(true) -- (use roads to get to CONTROL2)
  :addControlZone("CONTROL2")
  :setUseRoads(false) -- (don't use roads to get to CONTROL3)
  :addControlZone("CONTROL3")
  :setReinforceTimer(1200)
  :reinforce()



autogft_TaskForce:new()
  :setCountry(country.id.USA)
  :addUnits(4, "M-1 Abrams")
  :addBaseZone("BLUE_BASE")
  :addControlZone("CONTROL1")
  :setUseRoads(true)
  :addControlZone("CONTROL2")
  :setUseRoads(false)
  :addControlZone("CONTROL4")
  :setReinforceTimer(1200)
  :reinforce()
  