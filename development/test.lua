-- Script used for testing during development
devInitTargetVal = 0
if (devInitVal == nil or devInitVal ~= devInitTargetVal) then
  assert(loadfile([[C:\Users\birge\Workspace\dcs-bajas\bajas\bajas.lua]]))()

--  bajas.registerReinforcementSetup(bajas.ReinforcementSetup:new("M-1 Abrams", 2, country.id.USA, {"spawnB1", "spawnB2"}, "combatZone1"), 60)
--  bajas.registerReinforcementSetup(bajas.ReinforcementSetup:new("M-1 Abrams", 2, country.id.USA, {"spawnB1", "spawnB2"}, "combatZone2"), 60)
--  bajas.registerReinforcementSetup(bajas.ReinforcementSetup:new("M-1 Abrams", 2, country.id.USA, {"spawnB1", "spawnB2"}, "combatZone3"), 60)
--  bajas.registerReinforcementSetup(bajas.ReinforcementSetup:new("T-90", 2, country.id.RUSSIA, {"spawnR1"}, "combatZone1"), 60)
--  bajas.registerReinforcementSetup(bajas.ReinforcementSetup:new("T-90", 2, country.id.RUSSIA, {"spawnR1"}, "combatZone2"), 60)
--  bajas.registerReinforcementSetup(bajas.ReinforcementSetup:new("T-90", 2, country.id.RUSSIA, {"spawnR1"}, "combatZone3"), 60)

  local function callback(name)
    local group = Group.getByName(name)
    bajas.informOfClosestEnemyVehicles(group)
  end
  
  local function addCommandForGroups(groups)
    for i=1, #groups do
      bajas.registerGroupCommand(groups[i]:getName(), "TEST", callback)
    end
  end

  addCommandForGroups(coalition.getGroups(1))
  addCommandForGroups(coalition.getGroups(2))
  bajas.debug("Test script initialized")

  devInitVal = devInitTargetVal
end
