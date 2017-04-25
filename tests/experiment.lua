
if not initialized then

  assert(loadfile([[C:\Users\Birger\Workspace\dcs-autogft\build\autogft-1_9-beta.lua]]))()

  local taskSequence = autogft_TaskSequence:new()
  taskSequence:addTask(autogft_CaptureTask:new("target1", coalition.getCountryCoalition(country.id.USA)))

  local group = autogft_Group:new(taskSequence)
  local unitSpecs = {
    autogft_UnitSpec:new(6, unitType.vehicle.tank.M1_Abrams)
  }
  
  local reinforcer = autogft_SelectingReinforcer:new()
  reinforcer:addBaseZone("spawn1")
  reinforcer:addBaseZone("spawn2")
  reinforcer:setCountryID(country.id.USA)
  reinforcer:setGroupUnitSpecs(group, unitSpecs)
  reinforcer:reinforce()

  initialized = true

end
