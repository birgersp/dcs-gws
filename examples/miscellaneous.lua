
---
-- Showing optional stuff you can do with a task force:
-- manually specifying country, groups and units
-- excellent skill,
-- max advancement distance 3km (route calculation),
-- low speed (5knots),
-- scanning units,
-- manually setting the advance timer to 600 second intervals,
-- manually setting the respawning timer to 300 second intervals,
-- reinforcing (in this case, by respawning) will only happen for a total of 1200 sec (20 min)

autogft_TaskForce:new()
  :setCountry(country.id.NORWAY)
  :addGroup():addUnits(1, unitType.vehicle.unarmed.Hummer)
  :addBaseZone("BLUE_BASE4")
  :addControlZone("CONTROL1")
  :setSkill("Excellent")
  :setMaxRouteDistance(3)
  :setSpeed(5)
  :setAdvancementTimer(300)
  :setRespawnTimer(300)
  :setReinforceTimerMax(1200)
  