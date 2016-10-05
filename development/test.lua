local minReinforceDelay = 1200
local minAdvanceDelay = 300

local taskForce1 = bajas.TaskForce:new(country.id.RUSSIA,"task5",{"task5", "task4", "task3", "task2", "task1"})
taskForce1:addUnitSpec(4,bajas.unitTypes.vehicles.Tanks.T72B)
taskForce1:addUnitSpec(4,bajas.unitTypes.vehicles.Tanks.T72B)
taskForce1:addUnitSpec(4,bajas.unitTypes.vehicles.IFV.BRDM2)
taskForce1:addUnitSpec(4,bajas.unitTypes.vehicles.IFV.BRDM2)
taskForce1:enableReinforceInterval(minReinforceDelay)
taskForce1:enableAdvanceInterval(minAdvanceDelay)

local taskForce2 = bajas.TaskForce:new(country.id.USA,"task1",{"task1", "task2", "task3", "task4", "task5"})
taskForce2:addUnitSpec(2,bajas.unitTypes.vehicles.Tanks.M1_Abrams)
taskForce2:addUnitSpec(2,bajas.unitTypes.vehicles.Tanks.T72B)
taskForce2:addUnitSpec(4,bajas.unitTypes.vehicles.IFV.LAV25)
taskForce2:addUnitSpec(4,bajas.unitTypes.vehicles.IFV.LAV25)
taskForce2:enableReinforceInterval(minReinforceDelay)
taskForce2:enableAdvanceInterval(minAdvanceDelay)