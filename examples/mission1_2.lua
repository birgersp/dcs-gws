-- Mission initialization
if (initialized == nil or initialized == false) then

  assert(loadfile([[C:\Users\birge\Workspace\dcs-bajas\bajas\bajas.lua]]))()

  local MIN_REINFORCEMENT_T = 1800
  local reinforcementSetups = {}

  ---
  --@param #bajas.RS setup
  local function reinforceOverrideSpawnNames(setup, tempSpawnNames)
    local spawnNamesCopy = bajas.deepCopy(setup.spawnNames)
    setup.spawnNames = tempSpawnNames
    bajas.reinforce(setup)
    setup.spawnNames = spawnNamesCopy
  end

  local zoneNames = {
    combatZone1 = "",
    combatZone2 = "",
    combatZone3 = "",
    combatZone4 = "",
    combatZone5 = "",
    combatZone6 = "",
    combatZone7 = "",

    spawnB10 = "",
    spawnB11 = "",
    spawnB12 = "",

    spawnB20 = "",
    spawnB21 = "",
    spawnB22 = "",
    spawnB23 = "",
    spawnB24 = "",

    spawnR10 = "",
    spawnR11 = "",
    spawnR12 = "",

    spawnR20 = "",
    spawnR21 = "",
    spawnR22 = "",
    spawnR23 = "",
  }

  for i,v in pairs(zoneNames) do
    zoneNames[i] = i
  end

  local rsBuilder = bajas.RSBuilder:new()
  rsBuilder:timeInterval(MIN_REINFORCEMENT_T)

  rsBuilder:country(country.id.USA)

  rsBuilder:spawnNames({zoneNames.spawnB21, zoneNames.spawnB22})
  rsBuilder:destinationName(zoneNames.combatZone1)

  rsBuilder:unitType(bajas.unitTypes.vehicles.Tanks.M1_Abrams):unitCount(4):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnB20})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.BRDM2):unitCount(2):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnB20})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.LAV25):unitCount(2):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnB20})

  rsBuilder:destinationName(zoneNames.combatZone3)

  rsBuilder:unitType(bajas.unitTypes.vehicles.Tanks.M1_Abrams):unitCount(4):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnB20})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.BRDM2):unitCount(2):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnB20})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.LAV25):unitCount(2):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnB20})

  rsBuilder:destinationName(zoneNames.combatZone5)

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.BMP3):unitCount(4):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnB24})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.BRDM2):unitCount(2):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnB24})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.LAV25):unitCount(4):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnB24})

  rsBuilder:spawnNames({zoneNames.spawnB21, zoneNames.spawnB23})
  rsBuilder:destinationName(zoneNames.combatZone7)

  rsBuilder:unitType(bajas.unitTypes.vehicles.Tanks.M1_Abrams):unitCount(4):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnB24})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.BRDM2):unitCount(2):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnB24})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.LAV25):unitCount(2):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnB24})

  -- Russian units

  rsBuilder:country(country.id.RUSSIA)

  rsBuilder:spawnNames({zoneNames.spawnR22, zoneNames.spawnR23})
  rsBuilder:destinationName(zoneNames.combatZone2)

  rsBuilder:unitType(bajas.unitTypes.vehicles.Tanks.T90):unitCount(4):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnR20})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.BRDM2):unitCount(2):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnR20})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.BTR80):unitCount(2):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnR20})

  rsBuilder:destinationName(zoneNames.combatZone4)

  rsBuilder:unitType(bajas.unitTypes.vehicles.Tanks.T90):unitCount(4):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnR20})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.BRDM2):unitCount(2):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnR20})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.BTR80):unitCount(2):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnR20})

  rsBuilder:spawnNames({zoneNames.spawnR21, zoneNames.spawnB22})
  rsBuilder:destinationName(zoneNames.combatZone5)

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.BMP3):unitCount(4):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnR20})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.BRDM2):unitCount(2):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnR20})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.BTR80):unitCount(4):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnR20})

  rsBuilder:destinationName(zoneNames.combatZone6)

  rsBuilder:unitType(bajas.unitTypes.vehicles.Tanks.T90):unitCount(4):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnR20})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.BRDM2):unitCount(2):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnR20})

  rsBuilder:unitType(bajas.unitTypes.vehicles.IFV.BTR80):unitCount(2):registerDelayed(MIN_REINFORCEMENT_T / 2)
  reinforceOverrideSpawnNames(rsBuilder:build(),{zoneNames.spawnR20})


  bajas.enableIOCEVForGroups()

  initialized = true
end
