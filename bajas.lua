bajas = {}

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
--@field #string spawnName
--@field #string destinationName
bajas.ReinforcementSetup = {}

---
--@return #bajas.ReinforcementSetup
function bajas.ReinforcementSetup.new(unitType, unitCount, country, spawnName, destinationName)
  local obj = {} ---@type #bajas.ReinforcementSetup
  obj.unitType = unitType
  obj.unitCount = unitCount
  obj.country = country
  obj.spawnName = spawnName
  obj.destinationName = destinationName
  return obj
end

---
--@param #bajas.ReinforcementSetup reinforcementSetup
function bajas.reinforce(reinforcementSetup)

  local xAdd = 5
  local yAdd = 5

  local units = {}
  local spawnZone = trigger.misc.getZone(reinforcementSetup.spawnName)
  for i = 1, reinforcementSetup.unitCount do
    local unitType = reinforcementSetup.unitType
    units[i] = {
      ["type"] = unitType,
      ["transportable"] =
      {
        ["randomTransportable"] = false,
      }, -- end of ["transportable"]
      ["x"] = spawnZone.point.x + xAdd*i,
      ["y"] = spawnZone.point.z - yAdd*i,
      ["name"] = "Unit no " .. lastCreatedUnitId,
      ["unitId"] = lastCreatedUnitId,
      ["skill"] = "Excellent",
      ["playerCanDrive"] = true
    }

    lastCreatedUnitId = lastCreatedUnitId + 1
  end

  local groupName = "Group #00" .. lastCreatedGroupId
  local groupData = {
    ["route"] =
    {}, -- end of ["route"]
    ["groupId"] = lastCreatedGroupId,
    ["units"] = units,
    ["name"] = groupName
  } -- end of [1]

  coalition.addGroup(reinforcementSetup.country, Group.Category.GROUND, groupData)
  lastCreatedGroupId = lastCreatedGroupId + 1

  local destinationZone = trigger.misc.getZone(reinforcementSetup.destinationName)
  local destinationZonePos2 = {
    x = destinationZone.point.x,
    y = destinationZone.point.z
  }
  local randomPointVars = {
    group = Group.getByName(groupName),
    point = destinationZonePos2,
    radius = destinationZone.radius,
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
