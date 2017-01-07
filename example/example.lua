
-- Autonomous Ground Force Tasking example script
-- https://github.com/birgersp/dcs-autogft

-- Lines beginning with "--" are comments and does not affect the code
-- Put the standalone script and this script in "do script file" actions in a mission start trigger
-- Remember to re-load this script to your mission after you have edited it, it is not necessary to re-load the standalone
-- Comments above code blocks explain what the code is doing



-- (SPAWNING EXAMPLE)
-- 1. Creates a task force of US units
-- 2. Adds zones "SPAWN1" and "SPAWN2" as base zones (for reinforcing the task force)
-- 3. Adds zones "Combat1", "Combat" and "Combat3" as target zones. "Combat1" will be the first target
-- 4. Adds a group of M1-Abrams
-- 5. Adds another group of LAV-25 and some more M1-Abrams
-- 5. Set the skill of this task force to be "Excellent" (default is "High")
-- 6. Respawns the task force (at the base zones)
-- 7. Sets a "advancement timer" which a time interval (in seconds) of how often orders will be updated and units will be set to move
-- 8. Sets a "respawn timer" which is a time interval of how often the task force will be reinforced by spawning new units

autogft_TaskForce:new()
  :setCountry(country.id.USA)
  :addBaseZone("SPAWN1")
  :addBaseZone("SPAWN2")
  :addControlZone("Combat1")
  :addControlZone("Combat2")
  :addControlZone("Combat3")
  :addGroup():addUnits(4, "M-1 Abrams")
  :addGroup():addUnits(4, "LAV-25"):addUnits(3, "M-1 Abrams")
  :respawn()
  :setAdvancementTimer(300)
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
  :addGroup(4, "T-90")
  :reinforce()
  :setAdvancementTimer(300)
  :setReinforceTimer(600)



-- (VARIOUS OTHER FEATURES EXAMPLE)
-- Another US task force;
-- using roads,
-- excellent skill,
-- max advancement distance 3km,
-- low speed (5knots),
-- scanning units
-- only keep respawning for 1200 sec (20 min)

autogft_TaskForce:new()
  :setCountry(country.id.USA)
  :addBaseZone("SPAWN1")
  :addControlZone("Combat1")
  :addControlZone("Combat2")
  :addControlZone("Combat3")
  :addGroup(2, "M-1 Abrams")
  :setUseRoads(true)
  :setSkill("Excellent")
  :setMaxRouteDistance(3)
  :setSpeed(5)
  :scanUnits("TF")
  :respawn()
  :setAdvancementTimer(300)
  :setRespawnTimer(300, 1200)
