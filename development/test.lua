-- Script used for testing during development
devInitTargetVal = 0
if (devInitVal == nil or devInitVal ~= devInitTargetVal) then
  assert(loadfile([[C:\Users\birge\Workspace\dcs-bajas\bajas\bajas.lua]]))()

  local builder = bajas.RSBuilder:new()
  builder
    :country(country.id.USA)
    :spawnNames({"spawnB1"})
    :destinationName("combatZone1")
    :unitType(bajas.unitTypes.vehicles.Tanks.M1_Abrams)
    :unitCount(2)
    :timeInterval(60)

  builder:register()

  bajas.enableIOCEVForGroups()
  bajas.debug("Test script initialized")

  devInitVal = devInitTargetVal
end
