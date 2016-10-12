if initialized == nil then
  assert(loadfile([[C:\Users\birge\Workspace\dcs-mission-intel\build\mint.lua]]))()
  
  local taskForce2 = mint.TaskForce:new(country.id.RUSSIA,{"spawn1"},{"task1", "task2"})
  taskForce2:addUnitSpec(4,unitType.vehicle.tank.T90)
  taskForce2:enableDefault()

  local taskForce1 = mint.TaskForce:new(country.id.USA,{"spawn2"},{"task2", "task1"})
  taskForce1:addUnitSpec(4,unitType.vehicle.tank.M1_Abrams)
  taskForce1:enableDefault()

  mint.enableIOCEVForGroups()

  initialized = true
end



