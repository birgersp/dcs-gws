if initialized == nil then
  assert(loadfile([[C:\Users\birge\Workspace\dcs-bajas\build\bajas.lua]]))()
  
  local taskForce1 = bajas.TaskForce:new(country.id.USA,{"task1"}, {"task2", "taskMid", "task3"})
  taskForce1:addUnitSpec(3,unitType.vehicle.tank.M1_Abrams)
  taskForce1:enableAutoIssue(300)
  taskForce1:enableAutoReinforce(120)
  
  local taskForce2 = bajas.TaskForce:new(country.id.RUSSIA,{"task4"}, {"task3", "taskMid", "task2"})
  taskForce2:addUnitSpec(3,unitType.vehicle.tank.T90)
  taskForce2:addUnitSpec(3,unitType.vehicle.tank.T90)
  taskForce2:enableAutoIssue(300)
  taskForce2:enableAutoReinforce(300)
  
  bajas.enableIOCEVForGroups()
  
  initialized = true
end

