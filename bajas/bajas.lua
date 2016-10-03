-- Namespace and constants

bajas = {
  -- Constants
  GROUP_COMMAND_FLAG_NAME = "groupCommandTrigger",
  CARDINAL_DIRECTIONS = {"N", "N/NE", "NE", "NE/E", "E", "E/SE", "SE", "SE/S", "S", "S/SW", "SW", "SW/W", "W", "W/NW", "NW", "NW/N"},
  MAX_CLUSTER_DISTANCE = 1000,
  IOCEV_COMMAND_TEXT = "Request location of closest enemy vehicles",
  ZONE_STATUS = {
    CONTESTED = coalition.side.NEUTRAL,
    RED = coalition.side.RED,
    BLUE = coalition.side.BLUE
  },

  -- Counters
  lastCreatedUnitId = 0,
  lastCreatedGroupId = 0,

  -- Misc
  debug = false
}

-- Type definitions

---Spawning group specification
--@type bajas.SpawnGroupSpec
--@field #string unitType
--@field #number unitCount
--@field #number country
--@field #list<#string> spawnNames
bajas.SpawnGroupSpec = {}
bajas.SpawnGroupSpec.__index = bajas.SpawnGroupSpec

---
--@param #bajas.SpawnGroupSpec self
--@param #string unitType
--@param #number unitCount
--@param #number country
--@param #list<#string> spawnNames
--@return #bajas.SpawnGroupSpec
function bajas.SpawnGroupSpec:new(unitType, unitCount, country, spawnNames)
  local self = setmetatable({}, bajas.SpawnGroupSpec)
  self.unitType = unitType
  self.unitCount = unitCount
  self.country = country
  self.spawnNames = spawnNames
  return self
end

-- RS (reinforcement setup) class

---
--@type bajas.RS
--@field #bajas.SpawnGroupSpec groupSpec
--@field #string destinationName
bajas.RS = {}
bajas.RS.__index = bajas.RS

---
--@param #bajas.RS self
--@param #bajas.SpawnGroupSpec groupSpec
--@param #string destinationName
--@return #bajas.RS
function bajas.RS:new(groupSpec, destinationName)
  local self = setmetatable({}, bajas.RS)
  self.groupSpec = groupSpec
  self.destinationName = destinationName
  return self
end

-- RSBuilder class

---
--@type bajas.RSBuilder
--@field #bajas.RS setup
--@field #number t
--@field #list<#string> initialSpawnNames
bajas.RSBuilder = {}
bajas.RSBuilder.__index = bajas.RSBuilder

---
--@param #bajas.RSBuilder self
--@return #bajas.RSBuilder
function bajas.RSBuilder:new()
  local self = setmetatable({}, bajas.RSBuilder)
  self.setup = bajas.RS:new(bajas.SpawnGroupSpec:new(nil,nil,nil,nil),nil)
  return self
end

---
--@param #bajas.RSBuilder self
--@param #string unitType
--@return #bajas.RSBuilder
function bajas.RSBuilder:unitType(unitType)
  self.setup.groupSpec.unitType = unitType
  return self
end

---
--@param #bajas.RSBuilder self
--@param #number unitCount
--@return #bajas.RSBuilder
function bajas.RSBuilder:unitCount(unitCount)
  self.setup.groupSpec.unitCount = unitCount
  return self
end

---
--@param #bajas.RSBuilder self
--@param #number country
--@return #bajas.RSBuilder
function bajas.RSBuilder:country(country)
  self.setup.groupSpec.country = country
  return self
end

---
--@param #bajas.RSBuilder self
--@param #list<#string> spawnNames
--@return #bajas.RSBuilder
function bajas.RSBuilder:spawnNames(spawnNames)
  self.setup.groupSpec.spawnNames = spawnNames
  return self
end

---
--@param #bajas.RSBuilder self
--@param #string destinationName
--@return #bajas.RSBuilder
function bajas.RSBuilder:destinationName(destinationName)
  self.setup.destinationName = destinationName
  return self
end

---
--@param #bajas.RSBuilder self
--@param #number timeInterval
--@return #bajas.RSBuilder
function bajas.RSBuilder:timeInterval(timeInterval)
  self.t = timeInterval
  return self
end

---
--@param #bajas.RSBuilder self
--@return #bajas.RS
function bajas.RSBuilder:build()
  return bajas.deepCopy(self.setup)
end

---
--@param #bajas.RSBuilder self
function bajas.RSBuilder:register()
  local t = self.t
  if self.initialSpawnNames == nil then
    t = 1
  else
    local spawnNamesCopy = bajas.deepCopy(self.setup.groupSpec.spawnNames)
    self.setup.groupSpec.spawnNames = self.initialSpawnNames
    bajas.reinforce(self.setup)
    self.setup.groupSpec.spawnNames = spawnNamesCopy
  end
  self:registerDelayed(t)
end

---
--@param #bajas.RSBuilder self
--@param #number delaySec
function bajas.RSBuilder:registerDelayed(delaySec)
  mist.scheduleFunction(bajas.registerReinforcementSetup,{self:build(), self.t}, timer.getTime() + delaySec)
end

---
--@param #bajas.RSBuilder self
--@param #list<#string> initialSpawnNames
--@return #bajas.RS
function bajas.RSBuilder:initialSpawns(initialSpawnNames)
  self.initialSpawnNames = initialSpawnNames
  return self
end

-- UnitCluster class

---
--@type bajas.UnitCluster
--@field #list<#string> unitNames
--@field DCSTypes#Vec2 midPoint
bajas.UnitCluster = {}
bajas.UnitCluster.__index = bajas.UnitCluster

---
--@param #bajas.UnitCluster self
--@return #bajas.UnitCluster
function bajas.UnitCluster:new()
  local self = setmetatable({}, bajas.UnitCluster)
  self.unitNames = {}
  self.midPoint = {}
  return self
end

-- Task zone class

---
--@type bajas.TaskZone
--@field #string zoneName
--@field #number status
bajas.TaskZone = {}
bajas.TaskZone.__index = bajas.TaskZone

---
--@param #bajas.TaskZone self
--@param #string zoneName
--@return #bajas.TaskZone
function bajas.TaskZone:new(zoneName)
  self = setmetatable({}, bajas.TaskZone)
  self.zoneName = zoneName
  self:updateStatus()
  return self
end

---
--@param #bajas.TaskZone self
function bajas.TaskZone:updateStatus()
  local redVehicles = mist.makeUnitTable({'[red][vehicle]'})
  local blueVehicles = mist.makeUnitTable({'[blue][vehicle]'})

  local newStatus = bajas.ZONE_STATUS.CONTESTED
  if #mist.getUnitsInZones(redVehicles, { self.zoneName }) > 0 then
    newStatus = bajas.ZONE_STATUS.RED
  end

  if #mist.getUnitsInZones(blueVehicles, { self.zoneName }) > 0 then
    if newStatus == bajas.ZONE_STATUS.RED then
      newStatus = bajas.ZONE_STATUS.CONTESTED
    else
      newStatus = bajas.ZONE_STATUS.BLUE
    end
  end
  self.status = newStatus
end

-- Task sequence

---
--@type bajas.TaskSequence
--@field #list<#bajas.TaskZone> zones
--@field #list<#bajas.SpawnGroupSpec> groupSpecs
bajas.TaskSequence = {}
bajas.TaskSequence.__index = bajas.TaskSequence

---
--@param #bajas.TaskSequence self
--@param #list<#string> zoneNames
--@return #bajas.TaskSequence
function bajas.TaskSequence:new(zoneNames)
  self = setmetatable({}, bajas.TaskSequence)
  self.zones = {}
  for i=1, #zoneNames do
    self.zones[i] = bajas.TaskZone:new(zoneNames[i])
  end
  self.groupSpecs = {}
  return self
end

---
--@param #bajas.TaskSequence self
--@param #bajas.SpawnGroupSpec groupSpec
function bajas.TaskSequence:addGroupSpec(groupSpec)
  self.groupSpecs[#self.groupSpecs+1] = groupSpec 
end

-- Utility function definitions

---
--@param #bajas.RS reinforcementSetup
function bajas.reinforce(reinforcementSetup)
  local spec = reinforcementSetup.groupSpec

  local xAdd = 20
  local yAdd = 20

  local units = {}

  local randomValue = math.random()
  local spawnZoneIndex = math.floor(randomValue * #spec.spawnNames + 1)
  local spawnZone = trigger.misc.getZone(spec.spawnNames[spawnZoneIndex])
  for i = 1, spec.unitCount do
    local unitType = spec.unitType
    units[i] = {
      ["type"] = unitType,
      ["transportable"] =
      {
        ["randomTransportable"] = false,
      },
      ["x"] = spawnZone.point.x + xAdd*i,
      ["y"] = spawnZone.point.z - yAdd*i,
      ["name"] = "Unit no " .. bajas.lastCreatedUnitId,
      ["unitId"] = bajas.lastCreatedUnitId,
      ["skill"] = "Excellent",
      ["playerCanDrive"] = true
    }

    bajas.lastCreatedUnitId = bajas.lastCreatedUnitId + 1
  end

  local groupName = "Group #00" .. bajas.lastCreatedGroupId
  local groupData = {
    ["route"] = {},
    ["groupId"] = bajas.lastCreatedGroupId,
    ["units"] = units,
    ["name"] = groupName
  }

  coalition.addGroup(spec.country, Group.Category.GROUND, groupData)
  bajas.lastCreatedGroupId = bajas.lastCreatedGroupId + 1

  local destinationZone = trigger.misc.getZone(reinforcementSetup.destinationName)
  local destinationZonePos2 = {
    x = destinationZone.point.x,
    y = destinationZone.point.z
  }
  local randomPointVars = {
    group = Group.getByName(groupName),
    point = destinationZonePos2,
    radius = destinationZone.radius * 0.8,
    speed = 100,
    disableRoads = true
  }
  mist.groupToRandomPoint(randomPointVars)
end

---
--@param #bajas.RS setup
function bajas.reinforceCasualties(setup)

  local spec = setup.groupSpec

  -- Determine coalition search string
  local coalitionString = "[blue]"
  if coalition.getCountryCoalition(spec.country) == 1 then
    coalitionString = "[red]"
  end

  -- Count units of desired type in target zone
  local unitTableStr = coalitionString .. '[vehicle]'
  local defendingVehicles = mist.makeUnitTable({ unitTableStr })
  local reinforcementCount = spec.unitCount
  if (#defendingVehicles > 0) then
    local zoneVehicles = mist.getUnitsInZones(defendingVehicles, { setup.destinationName })
    for zoneVehicleIndex = 1, #zoneVehicles do
      if (Object.getTypeName(zoneVehicles[zoneVehicleIndex]) == spec.unitType) then
        reinforcementCount = reinforcementCount - 1
      end
    end
  end

  -- If there are any casualties, reinforce
  if (reinforcementCount > 0) then
    local initialUC = spec.unitCount
    spec.unitCount = reinforcementCount
    bajas.reinforce(setup)
    spec.unitCount = initialUC
  end
end

---
--@param #bajas.RS setup
--@param #number timeInterval Minimum time between reinforcement waves (sec)
function bajas.registerReinforcementSetup(setup, timeInterval)
  return mist.scheduleFunction(bajas.reinforceCasualties, {setup}, timer.getTime()+1, timeInterval)
end

---
--@param #number groupName
--@param #string commandName
--@param #function callback
function bajas.registerGroupCommand(groupName, commandName, callback)

  local group = Group.getByName(groupName)
  local groupId = group:getID()
  local flagName = bajas.GROUP_COMMAND_FLAG_NAME..groupId
  trigger.action.setUserFlag(flagName, 0)
  trigger.action.addOtherCommandForGroup(groupId, commandName, flagName, 1)

  local function checkTrigger()
    if (trigger.misc.getUserFlag(flagName) == 1) then
      trigger.action.setUserFlag(flagName, 0)
      callback(groupName)
    end
  end

  mist.scheduleFunction(checkTrigger, nil, timer.getTime()+1, 1)

end

---
--@param #vec3
--@param #vec3
--@return #number
function bajas.getDistanceBetween(a, b)
  local dx = a.x - b.x
  local dy = a.y - b.y
  local dz = a.z - b.z
  return math.sqrt(dx*dx + dy*dy + dz*dz)
end

---
--@param #string unitName
--@return DCSUnit#Unit
function bajas.getClosestEnemyVehicle(unitName)

  local unit = Unit.getByName(unitName)
  local unitPosition = unit:getPosition().p
  local enemyUnitPosition = {}
  local enemyCoalitionString = "[red]"
  if unit:getCoalition() == 1 then
    enemyCoalitionString = "[blue]"
  end
  local unitTableStr = enemyCoalitionString .. '[vehicle]'
  local enemyVehicles = mist.makeUnitTable({ unitTableStr })
  if #enemyVehicles > 0 then
    local closestEnemy = Unit.getByName(enemyVehicles[1])
    enemyUnitPosition = closestEnemy:getPosition().p
    local closestEnemyDistance = bajas.getDistanceBetween(unitPosition, enemyUnitPosition)
    local newClosestEnemy = {}
    local newClosestEnemyDistance = 0
    for i=2, #enemyVehicles do
      newClosestEnemy = Unit.getByName(enemyVehicles[i])
      newClosestEnemyDistance = bajas.getDistanceBetween(unitPosition, newClosestEnemy:getPosition().p)
      if (newClosestEnemyDistance < closestEnemyDistance) then
        closestEnemy = newClosestEnemy
      end
    end
    return closestEnemy
  end
end

---
--@param #number rad Direction in radians
--@return #string A string representing a cardinal direction
function bajas.radToCardinalDir(rad)

  local dirNormalized = rad / math.pi / 2
  local i = 1
  if dirNormalized < (#bajas.CARDINAL_DIRECTIONS-1) / #bajas.CARDINAL_DIRECTIONS then
    while dirNormalized > i/#bajas.CARDINAL_DIRECTIONS/2 do
      i = i+2
    end
  end
  local index = math.floor(i/2) + 1
  return bajas.CARDINAL_DIRECTIONS[index]
end

---
--This function might be computationally expensive
--@param DCSUnit#Unit unit
--@param #number radius
--@return #bajas.UnitCluster
function bajas.getFriendlyVehiclesWithin(unit, radius)
  local coalitionString
  if unit:getCoalition() == coalition.side.BLUE then
    coalitionString = "[blue]"
  else
    coalitionString  = "[red]"
  end
  local unitTableStr = coalitionString .. '[vehicle]'
  local units = mist.makeUnitTable({ unitTableStr })

  local addedVehiclesNames = {unit:getName()}
  local minPos = unit:getPosition().p
  local maxPos = unit:getPosition().p

  ---
  --@param #list list
  --@param value
  local function contains(list, value)
    for i=1, #list do
      if list[i] == value then
        return true
      end
    end
    return false
  end

  ---
  --@param DCSUnit#Unit unit
  local function addUnit(unit)
    local pos = unit:getPosition().p
    if pos.x < minPos.x then minPos.x = pos.x end
    if pos.z < minPos.z then minPos.z = pos.z end
    if pos.x > maxPos.x then maxPos.x = pos.x end
    if pos.z > maxPos.z then maxPos.z = pos.z end
    addedVehiclesNames[#addedVehiclesNames+1] = unit:getName()
  end

  ---
  --@param DCSUnit#Unit unit
  local function vehiclesWithinRecurse(targetUnit)
    for i=1, #units do
      local nextUnit = Unit.getByName(units[i])
      if nextUnit:getID() == targetUnit:getID() == false then
        if bajas.getDistanceBetween(targetUnit:getPosition().p,nextUnit:getPosition().p) <= radius then
          if contains(addedVehiclesNames, nextUnit:getName()) == false then
            addUnit(nextUnit)
            vehiclesWithinRecurse(nextUnit)
          end
        end
      end
    end
  end

  vehiclesWithinRecurse(unit)

  local dx = maxPos.x - minPos.x
  local dz = maxPos.z - minPos.z

  local midPoint = { -- 3D to 2D conversion implemented
    x = minPos.x + dx / 2,
    y = minPos.z + dz / 2
  }

  local result = bajas.UnitCluster:new()
  result.unitNames = addedVehiclesNames
  result.midPoint = midPoint
  return result

end

---
--Prints out a message to a group, describing nearest enemy vehicles
--@param DCSGroup#Group group
function bajas.informOfClosestEnemyVehicles(group)

  local firstGroupUnit = group:getUnit(1)
  local closestEnemy = bajas.getClosestEnemyVehicle(firstGroupUnit:getName())
  local groupUnitPos = {
    x = firstGroupUnit:getPosition().p.x,
    y = 0,
    z = firstGroupUnit:getPosition().p.z
  }

  local enemyCluster = bajas.getFriendlyVehiclesWithin(closestEnemy,bajas.MAX_CLUSTER_DISTANCE)
  local midPoint = mist.utils.makeVec3(enemyCluster.midPoint)

  local dir = mist.utils.getDir(mist.vec.sub(midPoint, groupUnitPos))
  local cardinalDir = bajas.radToCardinalDir(dir)
  local distance = bajas.getDistanceBetween(midPoint, groupUnitPos)
  local distanceKM = math.floor(distance / 1000 + 0.5)

  local vehicleTypes = {}
  for i=1, #enemyCluster.unitNames do
    local type = Unit.getByName(enemyCluster.unitNames[i]):getTypeName()
    if vehicleTypes[type] == nil then
      vehicleTypes[type] = 0
    end

    vehicleTypes[type] = vehicleTypes[type] + 1
  end

  local text = ""
  for key,val in pairs(vehicleTypes) do
    if (text ~= "") then
      text = text..", "
    end
    text = text..val.." "..key
  end

  text = text .. " located " .. distanceKM .. "km " .. cardinalDir
  trigger.action.outTextForGroup(group:getID(), text, 30)

end

function bajas.enableIOCEVForGroups()
  local function callback(name)
    local group = Group.getByName(name)
    bajas.informOfClosestEnemyVehicles(group)
  end

  local function addCommandForGroups(groups)
    for i=1, #groups do
      bajas.registerGroupCommand(groups[i]:getName(), bajas.IOCEV_COMMAND_TEXT, callback)
    end
  end

  addCommandForGroups(coalition.getGroups(1))
  addCommandForGroups(coalition.getGroups(2))
end

---Deep copy a table
--Code from https://gist.github.com/MihailJP/3931841
function bajas.deepCopy(t)
  if type(t) ~= "table" then return t end
  local meta = getmetatable(t)
  local target = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      target[k] = bajas.deepCopy(v)
    else
      target[k] = v
    end
  end
  setmetatable(target, meta)
  return target
end

---
--@param #string str
--@param #number time
function bajas.printIngame(str, time)
  if (time == nil) then
    time = 1
  end
  trigger.action.outText(str, time)
end

---
function bajas.debugVariable(variable)
  if bajas.debug then
    bajas.printIngame(bajas.toString(variable), 10)
  end
end

---Returns a string representation of an object
function bajas.toString(obj)

  local indent = "    "
  local function toStringRecursively(obj, level)

    if (obj == nil) then
      return "(nil)"
    end

    local str = ""
    if (type(obj) == "table") then
      if (level ~= 0) then
        str = str .. "{"
      end
      local isFirst = true
      for key, value in pairs(obj) do
        if (isFirst == false) then
          str = str .. ","
        end
        str = str .. "\n"
        for i = 1, level do
          str = str .. indent
        end

        if (type(key) == "number") then
          str = str .. "[\"" .. key .. "\"]"
        else
          str = str .. key
        end
        str = str .. " = "

        if (type(value) == "function") then
          str = str .. "(function)"
        else
          str = str .. toStringRecursively(value, level + 1)
        end
        isFirst = false
      end

      if (level ~= 0) then
        str = str .. "\n"
        for i = 1, level - 1 do
          str = str .. indent
        end
        str = str .. "}"
      end
    else
      str = obj
      if (type(obj) == "string") then
        str = "\"" .. str .. "\""
      elseif type(obj) == "boolean" then
        str = ""..obj
      end
    end

    return str
  end

  return toStringRecursively(obj, 1)
end

-- Unit type name constants

bajas.unitTypes = {}
bajas.unitTypes.navy = {}
bajas.unitTypes.navy.blue = {
  VINSON = "VINSON",
  PERRY = "PERRY",
  TICONDEROG = "TICONDEROG"
}
bajas.unitTypes.navy.red = {
  ALBATROS = "ALBATROS",
  KUZNECOW = "KUZNECOW",
  MOLNIYA = "MOLNIYA",
  MOSCOW = "MOSCOW",
  NEUSTRASH = "NEUSTRASH",
  PIOTR = "PIOTR",
  REZKY = "REZKY"
}
bajas.unitTypes.navy.civil = {
  ELNYA = "ELNYA",
  Drycargo_ship2 = "Dry-cargo ship-2",
  Drycargo_ship1 = "Dry-cargo ship-1",
  ZWEZDNY = "ZWEZDNY"
}
bajas.unitTypes.navy.submarine = {
  KILO = "KILO",
  SOM = "SOM"
}
bajas.unitTypes.navy.speedboat = {
  speedboat = "speedboat"
}
bajas.unitTypes.vehicles = {}
bajas.unitTypes.vehicles.Howitzers = {
  _2B11_mortar = "2B11 mortar",
  SAU_Gvozdika = "SAU Gvozdika",
  SAU_Msta = "SAU Msta",
  SAU_Akatsia = "SAU Akatsia",
  SAU_2C9 = "SAU 2-C9",
  M109 = "M-109"
}
bajas.unitTypes.vehicles.IFV = {
  AAV7 = "AAV7",
  BMD1 = "BMD-1",
  BMP1 = "BMP-1",
  BMP2 = "BMP-2",
  BMP3 = "BMP-3",
  Boman = "Boman",
  BRDM2 = "BRDM-2",
  BTR80 = "BTR-80",
  BTR_D = "BTR_D",
  Bunker = "Bunker",
  Cobra = "Cobra",
  LAV25 = "LAV-25",
  M1043_HMMWV_Armament = "M1043 HMMWV Armament",
  M1045_HMMWV_TOW = "M1045 HMMWV TOW",
  M1126_Stryker_ICV = "M1126 Stryker ICV",
  M113 = "M-113",
  M1134_Stryker_ATGM = "M1134 Stryker ATGM",
  M2_Bradley = "M-2 Bradley",
  Marder = "Marder",
  MCV80 = "MCV-80",
  MTLB = "MTLB",
  Paratrooper_RPG16 = "Paratrooper RPG-16",
  Paratrooper_AKS74 = "Paratrooper AKS-74",
  Sandbox = "Sandbox",
  Soldier_AK = "Soldier AK",
  Infantry_AK = "Infantry AK",
  Soldier_M249 = "Soldier M249",
  Soldier_M4 = "Soldier M4",
  Soldier_M4_GRG = "Soldier M4 GRG",
  Soldier_RPG = "Soldier RPG",
  TPZ = "TPZ"
}
bajas.unitTypes.vehicles.MLRS = {
  GradURAL = "Grad-URAL",
  Uragan_BM27 = "Uragan_BM-27",
  Smerch = "Smerch",
  MLRS = "MLRS"
}
bajas.unitTypes.vehicles.SAM = {
  _2S6_Tunguska = "2S6 Tunguska",
  Kub_2P25_ln = "Kub 2P25 ln",
  _5p73_s125_ln = "5p73 s-125 ln",
  S300PS_5P85C_ln = "S-300PS 5P85C ln",
  S300PS_5P85D_ln = "S-300PS 5P85D ln",
  SA11_Buk_LN_9A310M1 = "SA-11 Buk LN 9A310M1",
  Osa_9A33_ln = "Osa 9A33 ln",
  Tor_9A331 = "Tor 9A331",
  Strela10M3 = "Strela-10M3",
  Strela1_9P31 = "Strela-1 9P31",
  SA11_Buk_CC_9S470M1 = "SA-11 Buk CC 9S470M1",
  SA8_Osa_LD_9T217 = "SA-8 Osa LD 9T217",
  Patriot_AMG = "Patriot AMG",
  Patriot_ECS = "Patriot ECS",
  Gepard = "Gepard",
  Hawk_pcp = "Hawk pcp",
  SA18_Igla_manpad = "SA-18 Igla manpad",
  SA18_Igla_comm = "SA-18 Igla comm",
  Igla_manpad_INS = "Igla manpad INS",
  SA18_IglaS_manpad = "SA-18 Igla-S manpad",
  SA18_IglaS_comm = "SA-18 Igla-S comm",
  Vulcan = "Vulcan",
  Hawk_ln = "Hawk ln",
  M48_Chaparral = "M48 Chaparral",
  M6_Linebacker = "M6 Linebacker",
  Patriot_ln = "Patriot ln",
  M1097_Avenger = "M1097 Avenger",
  Patriot_EPP = "Patriot EPP",
  Patriot_cp = "Patriot cp",
  Roland_ADS = "Roland ADS",
  S300PS_54K6_cp = "S-300PS 54K6 cp",
  Stinger_manpad_GRG = "Stinger manpad GRG",
  Stinger_manpad_dsr = "Stinger manpad dsr",
  Stinger_comm_dsr = "Stinger comm dsr",
  Stinger_manpad = "Stinger manpad",
  Stinger_comm = "Stinger comm",
  ZSU234_Shilka = "ZSU-23-4 Shilka",
  ZU23_Emplacement_Closed = "ZU-23 Emplacement Closed",
  ZU23_Emplacement = "ZU-23 Emplacement",
  ZU23_Closed_Insurgent = "ZU-23 Closed Insurgent",
  Ural375_ZU23_Insurgent = "Ural-375 ZU-23 Insurgent",
  ZU23_Insurgent = "ZU-23 Insurgent",
  Ural375_ZU23 = "Ural-375 ZU-23"
}
bajas.unitTypes.vehicles.radar = {
  _1L13_EWR = "1L13 EWR",
  Kub_1S91_str = "Kub 1S91 str",
  S300PS_40B6M_tr = "S-300PS 40B6M tr",
  S300PS_40B6MD_sr = "S-300PS 40B6MD sr",
  _55G6_EWR = "55G6 EWR",
  S300PS_64H6E_sr = "S-300PS 64H6E sr",
  SA11_Buk_SR_9S18M1 = "SA-11 Buk SR 9S18M1",
  Dog_Ear_radar = "Dog Ear radar",
  Hawk_tr = "Hawk tr",
  Hawk_sr = "Hawk sr",
  Patriot_str = "Patriot str",
  Hawk_cwar = "Hawk cwar",
  p19_s125_sr = "p-19 s-125 sr",
  Roland_Radar = "Roland Radar",
  snr_s125_tr = "snr s-125 tr"
}
bajas.unitTypes.vehicles.Structures = {
  house1arm = "house1arm",
  house2arm = "house2arm",
  outpost_road = "outpost_road",
  outpost = "outpost",
  houseA_arm = "houseA_arm"
}
bajas.unitTypes.vehicles.Tanks = {
  Challenger2 = "Challenger2",
  Leclerc = "Leclerc",
  Leopard1A3 = "Leopard1A3",
  Leopard2 = "Leopard-2",
  M60 = "M-60",
  M1128_Stryker_MGS = "M1128 Stryker MGS",
  M1_Abrams = "M-1 Abrams",
  T55 = "T-55",
  T72B = "T-72B",
  T80UD = "T-80UD",
  T90 = "T-90"
}
bajas.unitTypes.vehicles.unarmed = {
  Ural4320_APA5D = "Ural-4320 APA-5D",
  ATMZ5 = "ATMZ-5",
  ATZ10 = "ATZ-10",
  GAZ3307 = "GAZ-3307",
  GAZ3308 = "GAZ-3308",
  GAZ66 = "GAZ-66",
  M978_HEMTT_Tanker = "M978 HEMTT Tanker",
  HEMTT_TFFT = "HEMTT TFFT",
  IKARUS_Bus = "IKARUS Bus",
  KAMAZ_Truck = "KAMAZ Truck",
  LAZ_Bus = "LAZ Bus",
  Hummer = "Hummer",
  M_818 = "M 818",
  MAZ6303 = "MAZ-6303",
  Predator_GCS = "Predator GCS",
  Predator_TrojanSpirit = "Predator TrojanSpirit",
  Suidae = "Suidae",
  Tigr_233036 = "Tigr_233036",
  Trolley_bus = "Trolley bus",
  UAZ469 = "UAZ-469",
  Ural_ATsP6 = "Ural ATsP-6",
  Ural375_PBU = "Ural-375 PBU",
  Ural375 = "Ural-375",
  Ural432031 = "Ural-4320-31",
  Ural4320T = "Ural-4320T",
  VAZ_Car = "VAZ Car",
  ZiL131_APA80 = "ZiL-131 APA-80",
  SKP11 = "SKP-11",
  ZIL131_KUNG = "ZIL-131 KUNG",
  ZIL4331 = "ZIL-4331"
}
