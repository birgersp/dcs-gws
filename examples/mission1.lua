-- Mission initialization
if (initialized == nil or initialized == false) then
  local MIN_REINFORCEMENT_T = 1800
  local reinforcementSetups = {}

  ---
  --@param #bajas.ReinforcementSetup setup
  --@param #list<#string> spawnNamesOverride
  local function reinforceImmediately(setup, spawnNamesOverride)
    local initialSpawnNames = bajas.deepCopy(setup.spawnNames)
    setup.spawnNames = spawnNamesOverride
    bajas.reinforce(setup)
    setup.spawnNames = initialSpawnNames
  end

  local function addAndSpawnSetup(unitType,unitCount,country,spawnNames,defenceName,firstSpawnNames)
    local rs = bajas.ReinforcementSetup:new(unitType,unitCount,country,spawnNames,defenceName)
    reinforceImmediately(rs,firstSpawnNames)
    reinforcementSetups[#reinforcementSetups+1] = rs
  end

  -- Some type names:
  -- BRDM-2
  -- BMP-3
  -- T-55
  -- T-72B
  -- T-90

  -- M-1 Abrams
  -- Leopard-2

  -- Reinforcement setups
  addAndSpawnSetup("BMP-3", 3, country.id.USA, {"spawnB1.1", "spawnB1.2"}, "defenceB1", {"spawnB1.0"})
  addAndSpawnSetup("BRDM-2", 2, country.id.USA, {"spawnB1.1", "spawnB1.2"}, "defenceB1", {"spawnB1.0"})
  addAndSpawnSetup("LAV-25", 4, country.id.USA, {"spawnB1.1", "spawnB1.2"}, "defenceB1", {"spawnB1.0"})

  addAndSpawnSetup("BMP-3", 3, country.id.USA, {"spawnB2.1","spawnB2.2"}, "defenceB2", {"spawnB2.0"})
  addAndSpawnSetup("BRDM-2", 2, country.id.USA, {"spawnB2.1","spawnB2.2"}, "defenceB2", {"spawnB2.0"})
  addAndSpawnSetup("LAV-25", 4, country.id.USA, {"spawnB2.1","spawnB2.2"}, "defenceB2", {"spawnB2.0"})
  addAndSpawnSetup("M-1 Abrams", 3, country.id.USA, {"spawnB2.1","spawnB2.2"}, "defenceB2", {"spawnB2.0"})

  addAndSpawnSetup("BMP-3", 3, country.id.RUSSIA, {"spawnR1.1","spawnR1.2"}, "defenceR1", {"spawnR1.0"})
  addAndSpawnSetup("BRDM-2", 2, country.id.RUSSIA, {"spawnR1.1","spawnR1.2"}, "defenceR1", {"spawnR1.0"})
  addAndSpawnSetup("BTR-80", 4, country.id.RUSSIA, {"spawnR1.1","spawnR1.2"}, "defenceR1", {"spawnR1.0"})

  addAndSpawnSetup("BMP-3", 3, country.id.RUSSIA, {"spawnR2.1","spawnR2.2"}, "defenceR2", {"spawnR2.0"})
  addAndSpawnSetup("BRDM-2", 2, country.id.RUSSIA, {"spawnR2.1","spawnR2.2"}, "defenceR2", {"spawnR2.0"})
  addAndSpawnSetup("BTR-80", 4, country.id.RUSSIA, {"spawnR2.1","spawnR2.2"}, "defenceR2", {"spawnR2.0"})
  addAndSpawnSetup("T-72B", 3, country.id.RUSSIA, {"spawnR2.1","spawnR2.2"}, "defenceR2", {"spawnR2.0"})

  for i=1, #reinforcementSetups do
    local setup = reinforcementSetups[i]
    mist.scheduleFunction(bajas.registerReinforcementSetup,{setup, MIN_REINFORCEMENT_T},timer.getTime() + MIN_REINFORCEMENT_T)
  end
  
  bajas.enableIOCEVForGroups()

  initialized = true
end
