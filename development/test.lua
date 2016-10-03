-- Script used for testing during development
devInitTargetVal = 0
if (devInitVal == nil or devInitVal ~= devInitTargetVal) then
  assert(loadfile([[C:\Users\birge\Workspace\dcs-bajas\bajas\bajas.lua]]))()
  bajas.debug = true

  local builder = bajas.RSBuilder:new()
  builder
    :country(country.id.USA)
    :spawnNames({"spawnB1"})
    :destinationName("combatZone1")
    :unitType(bajas.unitTypes.vehicles.Tanks.M1_Abrams)
    :unitCount(2)
    :timeInterval(60)

  -- Create task sequence
  local taskSequence = bajas.TaskSequence:new({"taskZone1","taskZone2","taskZone3"})
  taskSequence:addGroupSpec(builder:build().groupSpec)

  builder:register()

  bajas.enableIOCEVForGroups()

  devInitVal = devInitTargetVal
end
