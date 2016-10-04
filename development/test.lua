-- Script used for testing during development
devInitTargetVal = 1
if (devInitVal == nil or devInitVal ~= devInitTargetVal) then
  assert(loadfile([[C:\Users\birge\Workspace\dcs-bajas\bajas\bajas.lua]]))()
  bajas.debug = true

  local taskForce1 = bajas.TaskForce:new(country.id.USA,"task1",{"task2", "task3"})
  taskForce1:addUnitSpec(3, bajas.unitTypes.vehicles.Tanks.M1_Abrams)
  taskForce1:addUnitSpec(3, bajas.unitTypes.vehicles.IFV.LAV25)
  taskForce1:reinforce()
  
  local function advance()
    taskForce1:advance()
  end
  
  mist.scheduleFunction(advance, nil, timer.getTime()+1, 60)
  
--  local taskForce2 = bajas.TaskForce:new(country.id.RUSSIA,"task2")
--  taskForce2:addUnitSpec(3, bajas.unitTypes.vehicles.Tanks.T90)
--  taskForce2:addUnitSpec(3, bajas.unitTypes.vehicles.IFV.BMP2)
--  taskForce2:reinforce()

  devInitVal = devInitTargetVal
end
