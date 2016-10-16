
-- Autonomous Ground Force Tasking script example usage
-- (Lines beginning with "--" does not affect the mission)


-- Create a task force of US units, set "SPAWN1"/"SPAWN2" as the spawn zone and "Combat" "1", "2" and "3" as objectives
local usTaskForce = autogft.TaskForce:new(country.id.USA, {"SPAWN1", "SPAWN2"}, {"Combat1", "Combat2", "Combat3"})

-- Add 4 M-1 Abrams to the task force
usTaskForce:addUnitSpec(4, "M-1 Abrams")
-- Add another 4 M-1 Abrams to the task force
usTaskForce:addUnitSpec(4, "M-1 Abrams")
-- Add some LAV-25's
usTaskForce:addUnitSpec(4, "LAV-25")
-- Spawn the task force once
usTaskForce:respawn()
-- Enable automatic objective update every 120 seconds
usTaskForce:enableObjectiveUpdateTimer(120)
-- Enable automatic re-spawning of destroyed units every 300 seconds, for a total of 1200 seconds
usTaskForce:enableRespawnTimer(300,1200)


-- Create a task force of Russian units, with some different spawn zone and objectives
local russiaTaskForce1 = autogft.TaskForce:new(country.id.RUSSIA, {"SPAWN3"}, {"Combat3", "Combat2", "Combat1"})
-- Add some tanks for the task force
russiaTaskForce1:addUnitSpec(4, "T-90")
-- Spawn the tanks
russiaTaskForce1:respawn()
-- Enable automatic objective update 
russiaTaskForce1:enableObjectiveUpdateTimer(120)
-- Enable automatic re-spawning of destroyed units every 300 seconds
russiaTaskForce1:enableRespawnTimer(300) -- Not there is no second time value here, so this re-spawning will go on forever


-- Create a another Russian task force, spawning in (and defending) zone "Combat2"
local russiaTaskForce2 = autogft.TaskForce:new(country.id.RUSSIA, {"Combat2"}, {"Combat2"})
russiaTaskForce2:addUnitSpec(2, "BMP-2")
russiaTaskForce2:respawn()
russiaTaskForce2:enableObjectiveUpdateTimer(250)
russiaTaskForce2:enableRespawnTimer(120, 600)


-- Enable "Intel On Closest Enemy Vehicle" radio command option (F10) for players
-- Note: This is enabled 30 seconds after player group is activated
autogft.enableIOCEV()
