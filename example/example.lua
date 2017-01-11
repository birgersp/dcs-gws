
-- Autonomous Ground Force Tasking example script
-- https://github.com/birgersp/dcs-autogft

-- Lines beginning with "--" are comments and does not affect the code
-- Put the standalone script and this script in "do script file" actions in a mission start trigger
-- Remember to re-load this script to your mission after you have edited it, it is not necessary to re-load the standalone
-- Comments above code blocks explain what the code is doing



-- (BLUE TASK FORCE)
-- These lines of code:
-- creates a new task force,
-- adds zones "SPAWN1" and "SPAWN2" as base zones (for reinforcing the task force),
-- adds zones "Combat1", "Combat" and "Combat3" as control zone tasks. "Combat1" will be the first target

autogft_TaskForce:new()
  :addBaseZone("BLUE_BASE")
  :addControlZone("Combat1")
  :addControlZone("Combat2")
  :addControlZone("Combat3")



-- (RED TASK FORCE 1)

autogft_TaskForce:new()
  :addBaseZone("RED_BASE1")
  :addControlZone("Combat3")
  :addControlZone("Combat2")
  :addControlZone("Combat1")



-- (RED TASK FORCE 2)
-- (This task force will ignore "Combat1")

autogft_TaskForce:new()
  :addBaseZone("RED_BASE2")
  :addControlZone("Combat3")
  :addControlZone("Combat2")

  
  
-- (VARIOUS OTHER FEATURES EXAMPLE)
-- (Showing optional stuff you can do with the task force)
-- Another US task force;
-- manually specifying groups and units
-- using roads,
-- excellent skill,
-- max advancement distance 3km,
-- low speed (5knots),
-- scanning units,
-- manually setting the advance timer to 600 second intervals,
-- manually setting the respawning timer to 300 second intervals, for a total of 1200 sec (20 min)

autogft_TaskForce:new()
  :setCountry(country.id.USA)
  :addBaseZone("RED_BASE3")
  :addControlZone("Combat1")
  :addControlZone("Combat2")
  :addControlZone("Combat3")
  :addGroup():addUnits(4, "M-1 Abrams")
  :addGroup():addUnits(3, "M-1 Abrams")
  :setUseRoads(true)
  :setSkill("Excellent")
  :setMaxRouteDistance(3)
  :setSpeed(5)
  :scanUnits("TF")
  :respawn()
  :setAdvancementTimer(600)
  :setRespawnTimer(300, 1200)
  