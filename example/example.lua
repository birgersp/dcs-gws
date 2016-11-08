
-- Autonomous Ground Force Tasking script, example usage
-- (Lines beginning with "--" does not affect the mission)


-- Create a task force of US units, set "SPAWN1"/"SPAWN2" as the spawn zone and "Combat" "1", "2" and "3" as objectives
autogft.TaskForce:new(country.id.USA, {"SPAWN1", "SPAWN2"}, {"Combat1", "Combat2", "Combat3"})
  -- Add 4 M-1 Abrams to the task force
  :addUnitSpec(4, "M-1 Abrams")
  -- Add more units ...
  :addUnitSpec(3, "M-1 Abrams")
  -- Add some LAV-25's aswell
  :addUnitSpec(4, "LAV-25")
  -- Spawn the task force once (the "true" parameter specifies to spawn the units)
  :reinforce(true)
  -- Enable automatic objective update every 120 seconds
  :enableObjectiveUpdateTimer(120)
  -- Enable automatic re-spawning of destroyed units every 300 seconds, for a total of 1200 seconds
  :enableReinforcementTimer(300, true)


-- Create a task force of Russian units, with some different spawn zone and objectives
autogft.TaskForce:new(country.id.RUSSIA, {"STAGING1"}, {"Combat3", "Combat2", "Combat1"})
  :addUnitSpec(4, "T-90")
  -- (Note there is no "true" parameter in this reinforcement, so it will only use pre-spawned units)
  :enableObjectiveUpdateTimer(120)
  -- (Note there is no second time value in this timer, so this re-spawning will go on forever)
  :enableReinforcementTimer(10)

-- Enable "Intel On Closest Enemy Vehicle" radio command option (F10) for players
-- Note: This is enabled 30 seconds after player group is activated
autogft.enableIOCEV()
