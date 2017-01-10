
-- Autonomous Ground Force Tasking example script
-- https://github.com/birgersp/dcs-autogft

-- Lines beginning with "--" are comments and does not affect the code
-- Put the standalone script and this script in "do script file" actions in a mission start trigger
-- Remember to re-load this script to your mission after you have edited it, it is not necessary to re-load the standalone
-- Comments above code blocks explain what the code is doing



-- (SPAWNING EXAMPLE)
-- This example:
-- creates a US task force,
-- adds zones "SPAWN1" and "SPAWN2" as base zones (for reinforcing the task force),
-- adds zones "Combat1", "Combat" and "Combat3" as control zone tasks. "Combat1" will be the first target,
-- adds a group of M1-Abrams and LAV-25s,
-- respawns the task force (at the base zones), and
-- sets a "respawn timer" which is a time interval of how often the task force will be reinforced by spawning new units

autogft_TaskForce:new()
  :setCountry(country.id.USA)
  :addBaseZone("SPAWN1")
  :addBaseZone("SPAWN2")
  :addControlZone("Combat1")
  :addControlZone("Combat2")
  :addControlZone("Combat3")
  :addUnits(6, "M-1 Abrams")
  :addUnits(4, "LAV-25")
  :respawn()
  :setRespawnTimer(600)



-- (STAGING EXAMPLE)
-- Same as the previous code, but this time for some russian units and with a different base 
-- Note this task force will not respawn units. Only pre-existing units located in the base zone will be used to reinforce it

autogft_TaskForce:new()
  :setCountry(country.id.RUSSIA)
  :addBaseZone("STAGING1")
  :addControlZone("Combat3")
  :addControlZone("Combat2")
  :addControlZone("Combat1")
  :addUnits(4, "T-90")
  :reinforce()
  :setReinforceTimer(600)



-- (VARIOUS OTHER FEATURES EXAMPLE)
-- Another US task force;
-- units split into multiple groups
-- using roads,
-- excellent skill,
-- max advancement distance 3km,
-- low speed (5knots),
-- scanning units
-- advance every 600 seconds (instead of default value)
-- only keep respawning for 1200 sec (20 min)

autogft_TaskForce:new()
  :setCountry(country.id.USA)
  :addBaseZone("SPAWN1")
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
