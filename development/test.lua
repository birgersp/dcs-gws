-- Script used for testing during development
devInitTargetVal = 0
if (devInitVal == nil or devInitVal ~= devInitTargetVal) then
  assert(loadfile([[C:\Users\birge\Workspace\dcs-bajas\bajas\bajas.lua]]))()

  local builder = bajas.RSBuilder:new()
  builder
    :country(country.id.USA)
    :spawnNames({"spawnB1"})
    :destinationName("combatZone1")
    :unitType("M-1 Abrams")
    :unitCount(2)
    :timeInterval(60)

  builder:registerDelayed(10)

  --  bajas.registerReinforcementSetup(bajas.ReinforcementSetup:new("M-1 Abrams", 2, country.id.USA, {"spawnB1", "spawnB2"}, "combatZone1"), 60)
  --  bajas.registerReinforcementSetup(bajas.ReinforcementSetup:new("M-1 Abrams", 2, country.id.USA, {"spawnB1", "spawnB2"}, "combatZone2"), 60)
  --  bajas.registerReinforcementSetup(bajas.ReinforcementSetup:new("M-1 Abrams", 2, country.id.USA, {"spawnB1", "spawnB2"}, "combatZone3"), 60)
  --  bajas.registerReinforcementSetup(bajas.ReinforcementSetup:new("T-90", 2, country.id.RUSSIA, {"spawnR1"}, "combatZone1"), 60)
  --  bajas.registerReinforcementSetup(bajas.ReinforcementSetup:new("T-90", 2, country.id.RUSSIA, {"spawnR1"}, "combatZone2"), 60)
  --  bajas.registerReinforcementSetup(bajas.ReinforcementSetup:new("T-90", 2, country.id.RUSSIA, {"spawnR1"}, "combatZone3"), 60)

  bajas.enableIOCEVForGroups()
  bajas.debug("Test script initialized")

  devInitVal = devInitTargetVal
end
