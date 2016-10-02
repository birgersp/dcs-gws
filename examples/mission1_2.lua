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

local rsBuilder = bajas.RSBuilder:new()
rsBuilder:timeInterval(MIN_REINFORCEMENT_T)

-- USA units

rsBuilder:country(country.id.USA)

rsBuilder:initialSpawns({"spawnB20"})
rsBuilder:spawnNames({"spawnB21", "spawnB22"})

rsBuilder:destinationName("combatZone1")

rsBuilder:unitType(vehicles.Tanks.M1_Abrams):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.LAV25):unitCount(2):register()

rsBuilder:destinationName("combatZone3")

rsBuilder:unitType(vehicles.Tanks.M1_Abrams):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.LAV25):unitCount(2):register()

rsBuilder:initialSpawns({"spawnB24"})
rsBuilder:destinationName("combatZone5")

rsBuilder:unitType(vehicles.IFV.BMP3):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.LAV25):unitCount(4):register()

rsBuilder:spawnNames({"spawnB21", "spawnB23"})
rsBuilder:destinationName("combatZone7")

rsBuilder:unitType(vehicles.Tanks.M1_Abrams):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.LAV25):unitCount(2):register()

-- Russia units

rsBuilder:country(country.id.RUSSIA)

rsBuilder:initialSpawns({"spawnR20"})
rsBuilder:spawnNames({"spawnR22", "spawnR23"})

rsBuilder:destinationName("combatZone2")

rsBuilder:unitType(vehicles.Tanks.T90):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.BTR80):unitCount(2):register()

rsBuilder:destinationName("combatZone4")

rsBuilder:unitType(vehicles.Tanks.T90):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.BTR80):unitCount(2):register()

rsBuilder:spawnNames({"spawnR21", "spawnR22"})

rsBuilder:destinationName("combatZone5")

rsBuilder:unitType(vehicles.IFV.BMP3):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.BTR80):unitCount(4):register()

rsBuilder:destinationName("combatZone6")

rsBuilder:unitType(vehicles.Tanks.T90):unitCount(4):register()
rsBuilder:unitType(vehicles.IFV.BRDM2):unitCount(2):register()
rsBuilder:unitType(vehicles.IFV.BTR80):unitCount(2):register()

bajas.enableIOCEVForGroups()

initialized = true
