if initialized == nil then
  assert(loadfile([[C:\Users\birge\Workspace\dcs-bajas\build\bajas.lua]]))()
  
  local taskForce1 = bajas.TaskForce:new(country.id.USA,"task1", {"task1", "task2", "task3"})
  taskForce1:addUnitSpec(2,unitTypes.vehicles.tanks.M1_Abrams)
  taskForce1:addUnitSpec(2,unitTypes.vehicles.tanks.M1_Abrams)
  taskForce1:enableAdvanceInterval(300)
  taskForce1:enableReinforceInterval(60)
  
  local taskForce2 = bajas.TaskForce:new(country.id.RUSSIA,"task3", {"task3", "task2", "task1"})
  taskForce2:addUnitSpec(2,unitTypes.vehicles.tanks.T72B)
  taskForce2:addUnitSpec(2,unitTypes.vehicles.tanks.T72B)
  taskForce2:enableAdvanceInterval(300)
  taskForce2:enableReinforceInterval(60)
  
  initialized = true
end
