---
--@type bajas
--@field #list<#string#> CARDINAL_DIRECTIONS
--@field #string GROUP_COMMAND_FLAG_NAME
--@field #number MAX_CLUSTER_DISTANCE
--@field #number lastCreatedUnitId
--@field #number lastCreatedGroupId
bajas = {
  -- Constants
  GROUP_COMMAND_FLAG_NAME = "groupCommandTrigger",
  CARDINAL_DIRECTIONS = {"N", "N/NE", "NE", "NE/E", "E", "E/SE", "SE", "SE/S", "S", "S/SW", "SW", "SW/W", "W", "W/NW", "NW", "NW/N"},
  MAX_CLUSTER_DISTANCE = 1000,
  IOCEV_COMMAND_TEXT = "Request location of closest enemy vehicles",

  -- Counters
  lastCreatedUnitId = 0,
  lastCreatedGroupId = 0
}

---Deep copy a table
--Code from https://gist.github.com/MihailJP/3931841
function bajas.deepCopy(t)
  if type(t) ~= "table" then return t end
  local meta = getmetatable(t)
  local target = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      target[k] = clone(v)
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
function bajas.debug(variable)
  bajas.printIngame(bajas.toString(variable))
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

---
--@type bajas.ReinforcementSetup
--@field #string unitType
--@field #number unitCount
--@field #number country
--@field #list<#string> spawnNames
--@field #string destinationName
bajas.ReinforcementSetup = {}

---
--@param #bajas.ReinforcementSetup self
--@param #string unitType
--@param #number unitCount
--@param #number country
--@param #list<#string> spawnNames
--@param #string destinationName
--@return #bajas.ReinforcementSetup
function bajas.ReinforcementSetup:new(unitType, unitCount, country, spawnNames, destinationName)
  local self = bajas.deepCopy(self)
  self.unitType = unitType
  self.unitCount = unitCount
  self.country = country
  self.spawnNames = spawnNames
  self.destinationName = destinationName
  return self
end

---
--@param #bajas.ReinforcementSetup reinforcementSetup
function bajas.reinforce(reinforcementSetup)

  local xAdd = 20
  local yAdd = 20

  local units = {}

  local randomValue = math.random()
  local spawnZoneIndex = math.floor(randomValue * #reinforcementSetup.spawnNames + 1)
  local spawnZone = trigger.misc.getZone(reinforcementSetup.spawnNames[spawnZoneIndex])
  for i = 1, reinforcementSetup.unitCount do
    local unitType = reinforcementSetup.unitType
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

  coalition.addGroup(reinforcementSetup.country, Group.Category.GROUND, groupData)
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
--@param #bajas.ReinforcementSetup setup
function bajas.reinforceCasualties(setup)

  -- Determine coalition search string
  local coalitionString = "[blue]"
  if coalition.getCountryCoalition(setup.country) == 1 then
    coalitionString = "[red]"
  end

  -- Count units of desired type in target zone
  local unitTableStr = coalitionString .. '[vehicle]'
  local defendingVehicles = mist.makeUnitTable({ unitTableStr })
  local reinforcementCount = setup.unitCount
  if (#defendingVehicles > 0) then
    local zoneVehicles = mist.getUnitsInZones(defendingVehicles, { setup.destinationName })
    for zoneVehicleIndex = 1, #zoneVehicles do
      if (Object.getTypeName(zoneVehicles[zoneVehicleIndex]) == setup.unitType) then
        reinforcementCount = reinforcementCount - 1
      end
    end
  end

  -- If there are any casualties, reinforce
  if (reinforcementCount > 0) then
    local initialUC = setup.unitCount
    setup.unitCount = reinforcementCount
    bajas.reinforce(setup)
    setup.unitCount = initialUC
  end
end

---
--@param #bajas.ReinforcementSetup setup
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
--@type bajas.UnitCluster
--@field #list<#number> unitIDs
--@field #Vec2 midPoint
bajas.UnitCluster = {}

---
--@param #bajas.UnitCluster self
--@param #list<#number> unitIDs
--@param #Vec3 midPoint
function bajas.UnitCluster:new(unitIDs, midPoint)
  self = bajas.deepCopy(self)
  self.unitIDs = unitIDs
  self.midPoint = midPoint
  return self
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

  local addedVehiclesIDs = {unit:getID()}
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
    addedVehiclesIDs[#addedVehiclesIDs+1] = unit:getID()
  end

  ---
  --@param DCSUnit#Unit unit
  local function vehiclesWithinRecurse(targetUnit)
    for i=1, #units do
      local nextUnit = Unit.getByName(units[i])
      if nextUnit:getID() == targetUnit:getID() == false then
        if bajas.getDistanceBetween(targetUnit:getPosition().p,nextUnit:getPosition().p) <= radius then
          if contains(addedVehiclesIDs, nextUnit:getID()) == false then
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

  return bajas.UnitCluster:new(addedVehiclesIDs,midPoint)

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
  local text = #enemyCluster.unitIDs .. " enemy vehicles located " .. distanceKM .. "km " .. cardinalDir
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
