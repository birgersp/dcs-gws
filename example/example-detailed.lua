
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
  :setCountry(country.id.RUSSIA)
  :addBaseZone("RED_BASE3")
  :addControlZone("Combat3")
  :addControlZone("Combat2"):setUseRoads(true) -- (use roads to get to Combat2 and Combat1)
  :addControlZone("Combat1")
  :addGroup():addUnits(2, "T-90")
  :addGroup():addUnits(3, "T-55")
  :setSkill("Excellent")
  :setMaxRouteDistance(3)
  :setSpeed(5)
  :scanUnits("TF")
  :respawn()
  :setAdvancementTimer(300)
  :setRespawnTimer(300, 1200)