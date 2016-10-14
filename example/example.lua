-- Create a US task force, spawning at "spawn1" capturing task zones 1, 2 and 3
local taskForce1 = autogft.TaskForce:new(country.id.USA, {"spawn1"}, {"task1", "task2", "task3"})

-- Add 2 * 4 Abrams and 3 LAV-25s to it
taskForce1:addUnitSpec(4, unitType.vehicle.tank.M1_Abrams)
taskForce1:addUnitSpec(4, unitType.vehicle.tank.M1_Abrams)
taskForce1:addUnitSpec(3, unitType.vehicle.ifv.LAV25)

-- Set speed of groups (optional, default is max speed)
taskForce1.speed = 10

-- Set formation of groups (optional, default is "cone")
taskForce1.formation = "cone"

-- Reinforce (spawn) the task force
taskForce1:reinforce()

-- Enable automatic movement, orders updated every 120 seconds
taskForce1:enableMoveTimer(120)


-- Create a Russian task force
local taskForce2 = autogft.TaskForce:new(country.id.RUSSIA, {"spawn2"}, {"task3", "task2", "task1"})

-- Add 4 T-90's to it
taskForce2:addUnitSpec(4, unitType.vehicle.tank.T90)

-- Spawn this task force
taskForce2:reinforce()

-- Enable automatic movement
taskForce2:enableMoveTimer(120)

-- Enable automatic respawning, reinforcing the task force every 300 seconds
taskForce2:enableRespawnTimer(300)



-- Enable F10 option for players to get intel (heading and distance) on closest enemy vehicles 
autogft.enableIOCEV()
