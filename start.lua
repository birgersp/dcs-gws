bsputil = {}

function bsputil.printIngame(str, t)
  if (t == nil) then
    t = 1
  end
  trigger.action.outText(str, t)
end

function bsputil.debug(val)
  bsputil.printIngame(bsputil.toString(val))
end

-- Returns a string representation of an object
function bsputil.toString(obj)

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
--@type bsputil.ReinforcementSetup
--@field #string unitType
--@field #number unitCount
--@field #number country
--@field #string spawnName
--@field #string destinationName
bsputil.ReinforcementSetup = {}

---
--@return #bsputil.ReinforcementSetup
function bsputil.ReinforcementSetup.new(unitType, unitCount, country, spawnName, destinationName)
  local obj = {} ---@type #bsputil.ReinforcementSetup
  obj.unitType = unitType
  obj.unitCount = unitCount
  obj.country = country
  obj.spawnName = spawnName
  obj.destinationName = destinationName
  return obj
end

---
--@param #bsputil.ReinforcementSetup reinforcementSetup
function bsputil.reinforce(reinforcementSetup)

  local units = {}
  for i = 1, reinforcementSetup.unitCount do
    local spawnPoint = mist.getRandomPointInZone(reinforcementSetup.spawnName)
    local unitType = reinforcementSetup.unitType
    units[i] = {
      ["type"] = unitType,
      ["transportable"] =
      {
        ["randomTransportable"] = false,
      }, -- end of ["transportable"]
      ["x"] = spawnPoint.x,
      ["y"] = spawnPoint.y,
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
--@param #list<#bsputil.ReinforcementSetup> reinforcementSetups
function bsputil.checkAndReinforce(reinforcementSetups)

  for i = 1, #reinforcementSetups do
    local setup = reinforcementSetups[i]
    local coalitionString = "[blue]"
    if coalition.getCountryCoalition(setup.country) == 1 then
      coalitionString = "[red]"
    end

    local reinforcementCount = setup.unitCount
    local unitTableStr = coalitionString .. '[vehicle]'
    local defendingVehicles = mist.makeUnitTable({ unitTableStr })
    if (#defendingVehicles > 0) then
      local zoneVehicles = mist.getUnitsInZones(defendingVehicles, { setup.destinationName })
      for zoneVehicleIndex = 1, #zoneVehicles do
        if (Object.getTypeName(zoneVehicles[zoneVehicleIndex]) == setup.unitType) then
          reinforcementCount = reinforcementCount - 1
        end
      end
    end

    if (reinforcementCount > 0) then
      local initialUC = setup.unitCount
      setup.unitCount = reinforcementCount
      bsputil.reinforce(setup)
      setup.unitCount = initialUC
    end
  end
end



