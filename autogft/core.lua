---
-- @module core

-- Misc

autogft_debugMode = false

-- Utility function definitions

---
-- @param #list<DCSUnit#Unit> units
-- @param #string type
-- @return #number
function autogft_countUnitsOfType(units, type)
  local count = 0
  local unit
  for i = 1, #units do
    if units[i]:getTypeName() == type then
      count = count + 1
    end
  end
  return count
end

---
-- @param #vec3
-- @param #vec3
-- @return #number
function autogft_getDistanceBetween(a, b)
  local dx = a.x - b.x
  local dy = a.y - b.y
  local dz = a.z - b.z
  return math.sqrt(dx * dx + dy * dy + dz * dz)
end

---
-- @param #string unitName
-- @return DCSUnit#Unit
function autogft_getClosestEnemyVehicle(unitName)

  local unit = Unit.getByName(unitName)
  local unitPosition = unit:getPosition().p
  local enemyCoalitionString = "[red]"
  if unit:getCoalition() == 1 then
    enemyCoalitionString = "[blue]"
  end
  local unitTableStr = enemyCoalitionString .. '[vehicle]'
  local enemyVehicles = mist.makeUnitTable({ unitTableStr })
  if #enemyVehicles > 0 then
    local closestEnemy
    local closestEnemyDistance
    local newClosestEnemy = {}
    local newClosestEnemyDistance = 0
    for i = 1, #enemyVehicles do
      newClosestEnemy = Unit.getByName(enemyVehicles[i])
      if newClosestEnemy ~= nil then
        if closestEnemy == nil then
          closestEnemy = newClosestEnemy
          closestEnemyDistance = autogft_getDistanceBetween(unitPosition, closestEnemy:getPosition().p)
        else
          newClosestEnemyDistance = autogft_getDistanceBetween(unitPosition, newClosestEnemy:getPosition().p)
          if (newClosestEnemyDistance < closestEnemyDistance) then
            closestEnemy = newClosestEnemy
          end
        end
      end
    end
    return closestEnemy
  end
end

---
-- @function autogft_getUnitsInZones
-- @param #number coalitionId
-- @param #list<#string> zoneNames
function autogft_getUnitsInZones(coalitionId, zoneNames)
  local result = {}
  local groups = coalition.getGroups(coalitionId)
  for zoneNameIndex = 1, #zoneNames do
    local zone = trigger.misc.getZone(zoneNames[zoneNameIndex])
    local radiusSquared = zone.radius * zone.radius
    for groupIndex = 1, #groups do
      local units = groups[groupIndex]:getUnits()
      for unitIndex = 1, #units do
        local unit = units[unitIndex]
        local pos = unit:getPosition().p
        local dx = zone.point.x - pos.x
        local dy = zone.point.z - pos.z
        if (dx*dx + dy*dy) <= radiusSquared then
          result[#result + 1] = units[unitIndex]
        end
      end
    end
  end
  return result
end

---
-- @param #function func
-- @param #number time
function autogft_scheduleFunction(func, time)
  local function triggerFunction()
    local success, message = pcall(func)
    if not success then
      env.error("Error in scheduled function: "..message, true)
    end
  end
  timer.scheduleFunction(triggerFunction, {}, timer.getTime() + time)
end

---
-- Deep copy a table
-- Code from https://gist.github.com/MihailJP/3931841
function autogft_deepCopy(t)
  if type(t) ~= "table" then return t end
  local meta = getmetatable(t)
  local target = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      target[k] = autogft_deepCopy(v)
    else
      target[k] = v
    end
  end
  setmetatable(target, meta)
  return target
end

---
-- Returns a string representation of an object
function autogft_toString(obj)

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
        if obj == true then
          str = "true"
        else
          str = "false"
        end
      end
    end

    return str
  end

  return toStringRecursively(obj, 1)
end

---
-- @param #list list
-- @param # item
function autogft_contains(list, item)
  for i = 1, #list do
    if list[i] == item then return true end
  end
  return false
end

---
-- @param #string zoneName
function autogft_assertZoneExists(zoneName)
  assert(trigger.misc.getZone(zoneName) ~= nil, "Zone \""..zoneName.."\" does not exist in this mission.")
end
