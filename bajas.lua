
---
--@type bajas
--@field #number lastCreatedUnitId
--@field #number lastCreatedGroupId
bajas = {
  lastCreatedUnitId = 0,
  lastCreatedGroupId = 0
}

function bajas.printIngame(str, t)
  if (t == nil) then
    t = 1
  end
  trigger.action.outText(str, t)
end

function bajas.debug(val)
  bajas.printIngame(bajas.toString(val))
end

-- Returns a string representation of an object
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
        str = "true"
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
--@return #bajas.ReinforcementSetup
function bajas.ReinforcementSetup.new(unitType, unitCount, country, spawnNames, destinationName)
  local obj = {} ---@type #bajas.ReinforcementSetup
  obj.unitType = unitType
  obj.unitCount = unitCount
  obj.country = country
  obj.spawnNames = spawnNames
  obj.destinationName = destinationName
  return obj
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
    speed = 100
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
  mist.scheduleFunction(bajas.reinforceCasualties, {setup}, timer.getTime()+1, timeInterval)
end

---
--@param #number groupName
--@param #string commandName
--@param #function callback
function bajas.registerGroupCommand(groupName, commandName, callback)

  local group = Group.getByName(groupName)
  local groupId = group:getID()
  local flagName = "group"..groupId.."Trigger"
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
--@return #Unit
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
