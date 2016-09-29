-- Script used for mission development
-- Before mission deployment, remember to add the scripts to the mission
--devInitialized = false
if (devInitialized == nil or devInitialized == false) then
  assert(loadfile([[C:\Users\birge\Workspace\dcs-bajas\bajas.lua]]))()

  bajas.registerReinforcementSetup(bajas.ReinforcementSetup.new("M-1 Abrams", 3, country.id.USA, {"spawnB1", "spawnB2"}, "combatZone"), 120)
  bajas.registerReinforcementSetup(bajas.ReinforcementSetup.new("T-90", 3, country.id.RUSSIA, {"spawnR1"}, "combatZone"), 120)

  local function callback(name)
    local group = Group.getByName(name)
    local firstGroupUnit = group:getUnit(1)
    bajas.debug(bajas.getClosestEnemyVehicle(firstGroupUnit:getName()))
  end
  
  local function addCommandForGroups(groups)
    for i=1, #groups do
      bajas.registerGroupCommand(groups[i]:getName(), "TEST", callback)
    end
  end

  addCommandForGroups(coalition.getGroups(1))
  addCommandForGroups(coalition.getGroups(2))

  devInitialized = true
end
