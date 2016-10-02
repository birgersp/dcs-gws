assert(loadfile([[C:\Users\birge\Workspace\dcs-bajas\bajas\bajas.lua]]))()

local MIN_REINFORCEMENT_T = 1800
local reinforcementSetups = {}
local vehicles = bajas.unitTypes.vehicles

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

rsBuilder:initialSpawns({zoneNames.spawnB20})
rsBuilder:spawnNames({zoneNames.spawnB21, zoneNames.spawnB22})

rsBuilder:destinationName(zoneNames.combatZone1)

rsBuilder:unitType(vehicles.Tanks.M1_Abrams):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.LAV25):unitCount(2):register()

rsBuilder:destinationName(zoneNames.combatZone3)

rsBuilder:unitType(vehicles.Tanks.M1_Abrams):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.LAV25):unitCount(2):register()

rsBuilder:initialSpawns({zoneNames.spawnB24})
rsBuilder:destinationName(zoneNames.combatZone5)

rsBuilder:unitType(vehicles.IFV.BMP3):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.LAV25):unitCount(4):register()

rsBuilder:spawnNames({zoneNames.spawnB21, zoneNames.spawnB23})
rsBuilder:destinationName(zoneNames.combatZone7)

rsBuilder:unitType(vehicles.Tanks.M1_Abrams):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.LAV25):unitCount(2):register()

-- Russian units

rsBuilder:country(country.id.RUSSIA)

rsBuilder:initialSpawns({zoneNames.spawnR20})
rsBuilder:spawnNames({zoneNames.spawnR22, zoneNames.spawnR23})
rsBuilder:destinationName(zoneNames.combatZone2)

rsBuilder:unitType(vehicles.Tanks.T90):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.BTR80):unitCount(2):register()

rsBuilder:destinationName(zoneNames.combatZone4)

rsBuilder:unitType(vehicles.Tanks.T90):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.BTR80):unitCount(2):register()

rsBuilder:spawnNames({zoneNames.spawnR21, zoneNames.spawnB22})
rsBuilder:destinationName(zoneNames.combatZone5)

rsBuilder:unitType(vehicles.IFV.BMP3):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.BTR80):unitCount(4):register()

rsBuilder:destinationName(zoneNames.combatZone6)

rsBuilder:unitType(vehicles.Tanks.T90):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.BTR80):unitCount(2):register()

bajas.enableIOCEVForGroups()

initialized = true
