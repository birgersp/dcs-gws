
-- Autonomous Ground Force Tasking example script
-- https://github.com/birgersp/dcs-autogft
-- (Lines beginning with "--" are comments and does not affect the code)
-- (Remember to re-load this script to your mission after you have edited it)
-- Comments above code blocks explain what the code is doing



-- (SPAWNING EXAMPLE)
-- 1. Creates a task force of US units
-- 2. Adds zones "SPAWN1" and "SPAWN2" as base zones (for spawning or staging)
-- 3. Adds zones "Combat1", "Combat" and "Combat3" as target zones. "Combat1" will be the first target
-- 4. Adds two groups of M1-Abrams, and a group of 4 LAV-25s
-- 5. Respawns the task force (at the base zones)
-- 6. Sets a "target update timer" which a time interval (in seconds) of how often orders will be updated
-- 7. Sets a "respawn timer" which is a time interval of how often the task force will be reinforced by spawning new units

autogft.TaskForce:new()
  :setCountry(country.id.USA)
  :addBaseZone("SPAWN1")
  :addBaseZone("SPAWN2")
  :addTargetZone("Combat1")
  :addTargetZone("Combat2")
  :addTargetZone("Combat3")
  :addUnitSpec(4, "M-1 Abrams")
  :addUnitSpec(3, "M-1 Abrams")
  :addUnitSpec(4, "LAV-25")
  :respawn()
  :setTargetUpdateTimer(120)
  :setRespawnTimer(300)



-- (STAGING EXAMPLE)
-- Same as the previous code, but this time for some russian units and with a different base 
-- Note this task force will not respawn, but "re-stage" instead
-- This means the task force will only be reinforced by units that are located in the base prior to reinforcing 

autogft.TaskForce:new()
  :setCountry(country.id.RUSSIA)
  :addBaseZone("STAGING1")
  :addTargetZone("Combat3")
  :addTargetZone("Combat2")
  :addTargetZone("Combat1")
  :addUnitSpec(4, "T-90")
  :setTargetUpdateTimer(120)
  :setRestageTimer(10)



-- (INTEL ON CLOSEST ENEMY VEHICLE FEATURE)
-- Enable the "Intel On Closest Enemy Vehicle" radio command option (F10) for human players
-- Note: This is enabled 30 seconds after player group is activated

autogft.enableIOCEV()
