local taskForce1 = autogft.TaskForce:new(country.id.USA, {"SPAWN1"}, {"Combat1", "Combat2", "Combat3"})
taskForce1:addUnitSpec(4, unitType.vehicle.tank.M1_Abrams)
taskForce1:reinforce()
taskForce1:enableMoveTimer(120)
taskForce1:enableRespawnTimer(300,1200)



local taskForce2 = autogft.TaskForce:new(country.id.RUSSIA, {"SPAWN2"}, {"Combat3", "Combat2", "Combat1"})
taskForce2:addUnitSpec(4, unitType.vehicle.tank.T90)
taskForce2:reinforce()
taskForce2:moveToTarget()
taskForce2:enableMoveTimer(120)
taskForce2:enableRespawnTimer(300)



autogft.enableIOCEV()
