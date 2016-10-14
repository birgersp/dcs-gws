local taskForce1 = autogft.TaskForce:new(country.id.USA, {"spawn1"}, {"task1", "task2"})
taskForce1.speed = 10
taskForce1:addUnitSpec(3, unitType.vehicle.tank.M1_Abrams)
taskForce1:enableDefaultTimers()

local taskForce2 = autogft.TaskForce:new(country.id.RUSSIA, {"spawn2"}, {"task2", "task1"})
taskForce2:addUnitSpec(4, unitType.vehicle.tank.T90)
taskForce2:enableMoveTimer(120)
taskForce2:enableRespawnTimer(300) 

autogft.enableIOCEV()
