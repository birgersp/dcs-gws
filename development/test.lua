if initialized == nil then
  assert(loadfile([[C:\Users\birge\Workspace\dcs-bajas\build\bajas.lua]]))()
 
  local function enableTaskForce(tf)
    tf:enableAutoIssue(300)
    tf:enableAutoReinforce(120)
  end

  local taskForce1 = bajas.TaskForce:new(
    country.id.USA,
    {"spawnB4", "spawnB5", "spawnB3", "spawnB2"},
    {"task1", "task4", "task5", "task9", "task10", "task12"})
  taskForce1:addUnitSpec(4,unitType.vehicle.tank.M1_Abrams)
  taskForce1:addUnitSpec(4,unitType.vehicle.tank.M1_Abrams)
  taskForce1:addUnitSpec(4,unitType.vehicle.ifv.LAV25)
  taskForce1:addUnitSpec(4,unitType.vehicle.ifv.LAV25)
  taskForce1:addUnitSpec(4,unitType.vehicle.tank.Challenger2)
  enableTaskForce(taskForce1)

  local taskForce2 = bajas.TaskForce:new(
    country.id.USA,
    {"spawnB5", "spawnB3", "spawnB2"},
    {"task2", "task4", "task5", "task9", "task10", "task12"})
  taskForce2:addUnitSpec(4,unitType.vehicle.ifv.LAV25)
  taskForce2:addUnitSpec(3,unitType.vehicle.ifv.LAV25)
  taskForce2:addUnitSpec(4,unitType.vehicle.ifv.M2_Bradley)
  taskForce2:addUnitSpec(4,unitType.vehicle.ifv.M2_Bradley)
  taskForce2:addUnitSpec(4,unitType.vehicle.mlrs.MLRS)
  enableTaskForce(taskForce2)

  local taskForce3 = bajas.TaskForce:new(
    country.id.USA,
    {"spawnB1"},
    {"task3", "task6", "task7", "task8", "task11"})
  taskForce3:addUnitSpec(4,unitType.vehicle.tank.M1_Abrams)
  taskForce3:addUnitSpec(4,unitType.vehicle.tank.M1_Abrams)
  taskForce3:addUnitSpec(4,unitType.vehicle.ifv.LAV25)
  taskForce3:addUnitSpec(4,unitType.vehicle.ifv.LAV25)
  taskForce3:addUnitSpec(4,unitType.vehicle.tank.Challenger2)
  taskForce3:addUnitSpec(4,unitType.vehicle.mlrs.MLRS)
  enableTaskForce(taskForce3)

--  local taskForce2 = bajas.TaskForce:new(country.id.RUSSIA,{"spawnR1"}, {"task11", "task8"})
--  taskForce2:addUnitSpec(4,unitType.vehicle.tank.T90)
--  taskForce2:addUnitSpec(4,unitType.vehicle.tank.T90)
--  taskForce2:addUnitSpec(4,unitType.vehicle.ifv.BMP2)
--  taskForce2:addUnitSpec(4,unitType.vehicle.ifv.BRDM2)
--  taskForce2:enableAutoIssue(300)
--  taskForce2:enableAutoReinforce(300)

  bajas.enableIOCEVForGroups()

  initialized = true
end


