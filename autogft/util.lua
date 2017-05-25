---
-- @module Util

---
-- @type autogft
autogft = {}

autogft.unitTypeNameTerms = {} --#map<#string, #string>
autogft.unitTypeTerms = {
  MBT= "MBT",
  INFANTRY_FIGHTING_VEHICLE = "IFV",
  SAM = "SAM",
  INFANTRY = "INFANTRY"
}

do

  local function add(table, term)
    for _, name in pairs(table) do
      autogft.unitTypeNameTerms[name] = term
    end
  end

  add(unitType.vehicle.tank, autogft.unitTypeTerms.MBT)
  add(unitType.vehicle.ifv, autogft.unitTypeTerms.INFANTRY_FIGHTING_VEHICLE)
  add(unitType.vehicle.sam, autogft.unitTypeTerms.SAM)
  add(unitType.infantry, autogft.unitTypeTerms.INFANTRY)

end

-- Utility function definitions

---
-- @param #string unitTypeName
-- @return #string
function autogft.getUnitTypeNameTerm(unitTypeName)
  local term = autogft.unitTypeNameTerms[unitTypeName]
  if not term then
    term = unitTypeName
  end
  return term
end

---
-- @param DCSVec3#Vec3 position
-- @return #number
function autogft.getHeadingNorthCorrection(position)
  local latitude, longitude = coord.LOtoLL(position)
  local nortPosition = coord.LLtoLO(latitude + 1, longitude)
  return math.atan2(nortPosition.z - position.z, nortPosition.x - position.x)
end

---
-- @param DCSUnit#Unit unit
-- @return #number
function autogft.getUnitHeading(unit)
  local unitPosition = unit:getPosition()
  local unitPos = autogft_Vector3.getCopy(unitPosition.p)
  local heading = math.atan2(unitPosition.x.z, unitPosition.x.x) + autogft.getHeadingNorthCorrection(unitPos)
  if heading < 0 then
    heading = heading + 2 * math.pi
  end
  return heading
end

---
-- @param DCSUnit#Unit unit
-- @param DCSZone#Zone zone
-- @return #boolean
function autogft.unitIsWithinZone(unit, zone)
  local pos = unit:getPosition().p
  local dx = zone.point.x - pos.x
  local dy = zone.point.z - pos.z
  local radiusSquared = zone.radius * zone.radius
  if (dx*dx + dy*dy) <= radiusSquared then
    return true
  end
  return false
end

---
-- @param #list<DCSUnit#Unit> units
-- @param #string type
-- @return #number
function autogft.countUnitsOfType(units, type)
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
function autogft.getDistanceBetween(a, b)
  local dx = a.x - b.x
  local dy = a.y - b.y
  local dz = a.z - b.z
  return math.sqrt(dx * dx + dy * dy + dz * dz)
end

---
-- @param #number coalitionId
-- @param #list<DCSZone#Zone> zones
-- @return #list<DCSUnit#Unit>
function autogft.getUnitsInZones(coalitionId, zones)
  local addedUnitIDs = {}
  local result = {}
  local groups = coalition.getGroups(coalitionId)
  for _, zone in pairs(zones) do
    local radiusSquared = zone.radius * zone.radius
    for _, group in pairs(groups) do
      local units = group:getUnits()
      for unitIndex = 1, #units do
        local unit = units[unitIndex] --DCSUnit#Unit
        local unitID = unit:getID()
        if not addedUnitIDs[unitID] then
          local pos = unit:getPosition().p
          local dx = zone.point.x - pos.x
          local dy = zone.point.z - pos.z
          if (dx*dx + dy*dy) <= radiusSquared then
            result[#result + 1] = units[unitIndex]
            addedUnitIDs[unitID] = true
          end
        end
      end
    end
  end
  return result
end

---
-- @param #function func
-- @param #number time Seconds
-- @return #number Function id
function autogft.scheduleFunction(func, time)
  local function triggerFunction()
    local success, message = pcall(func)
    if not success then
      env.error("Error in scheduled function: "..message, true)
    end
  end
  return timer.scheduleFunction(triggerFunction, {}, timer.getTime() + time)
end

---
-- @param #string prefix (Optional)
-- @return #string
function autogft.getUniqueGroupName(prefix)
  local groupName
  local index = 0
  while (not groupName) or Group.getByName(groupName) do
    index = index + 1
    groupName = "autogft group #" .. index
    if prefix then groupName = prefix .. "-" .. groupName end
  end
  return groupName
end

---
-- @param DCSZone#Zone zone1
-- @param DCSZone#Zone zone2
function autogft.compareZones(zone1, zone2)
  return autogft_Vector3.equals(zone1.point, zone2.point)
end

---
-- @param DCSGroup#Group group
-- @return #boolean
function autogft.groupExists(group)
  local units = group:getUnits()
  for i = 1, #units do
    local unit = units[i] --DCSUnit#Unit
    if unit and unit:isExist() then
      return true
    end
  end
  return false
end

---
-- @param #string groupNamePrefix
function autogft.getUnitsByGroupNamePrefix(groupNamePrefix)

  local coalitionGroups = {
    coalition.getGroups(coalition.side.BLUE),
    coalition.getGroups(coalition.side.RED)
  }

  local availableUnits = {}

  local coalition = 1
  while coalition <= #coalitionGroups and #availableUnits == 0 do
    for _, group in pairs(coalitionGroups[coalition]) do
      if group:getName():find(groupNamePrefix) == 1 then
        local units = group:getUnits()
        for unitIndex = 1, #units do
          availableUnits[#availableUnits + 1] = units[unitIndex]
        end
      end
    end
    coalition = coalition + 1
  end

  return availableUnits
end

---
-- @param DCSUnit#Unit unit
-- @return #number
function autogft.getEnemyCoalitionID(unit)
  local result = coalition.side.RED
  if unit:getCoalition() == coalition.side.RED then
    result = coalition.side.BLUE
  end
  return result
end

---
-- @param DCSUnit#Unit unit
-- @param #number radius
-- @return #list<DCSUnit#Unit>
function autogft.getEnemyGroundUnitsWithin(unit, radius)

  local enemyGroundGroups = coalition.getGroups(autogft.getEnemyCoalitionID(unit), Group.Category.GROUND)
  local observerMaxDistance2 = radius^2
  local observerPosition = unit:getPosition().p

  -- Create list of enemy units within max distance
  local targetUnits = {}
  for enemyGroupI = 1, #enemyGroundGroups do
    local enemyGroup = enemyGroundGroups[enemyGroupI]
    if enemyGroup and enemyGroup:isExist() then
      local enemyUnits = enemyGroup:getUnits()
      for enemyUnitI = 1, #enemyUnits do
        local enemyUnit = enemyUnits[enemyUnitI] --DCSUnit#Unit
        if enemyUnit and enemyUnit:isExist() then
          local enemyPos = enemyUnit:getPosition().p
          local dX = enemyPos.x - observerPosition.x
          local dY = enemyPos.y - observerPosition.y
          local dZ = enemyPos.z - observerPosition.z
          local distance2 = dX*dX + dY*dY + dZ*dZ
          if distance2 <= observerMaxDistance2 then
            targetUnits[#targetUnits + 1] = enemyUnit
          end
        end
      end
    end
  end
  return targetUnits
end

---
-- Deep copy a table
-- Code from https://gist.github.com/MihailJP/3931841
function autogft.deepCopy(t)
  if type(t) ~= "table" then return t end
  local meta = getmetatable(t)
  local target = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      target[k] = autogft.deepCopy(v)
    else
      target[k] = v
    end
  end
  setmetatable(target, meta)
  return target
end

---
-- Returns a string representation of an object
function autogft.toString(obj)

  local stringifiedTableIDs = {}

  local indent = "    "
  local function toStringRecursively(obj, level)

    if (obj == nil) then
      return "(nil)"
    end

    local str = ""
    if (type(obj) == "table") then
      local tableID = tostring(obj):sub(8)

      str = str .. "(" .. tableID .. ")"
      if not stringifiedTableIDs[tableID] then
        stringifiedTableIDs[tableID] = true
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
          elseif (type(key) == "table") then
            str = str .. tostring(key)
          else
            str = str .. "\"" .. key .. "\""
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
function autogft.contains(list, item)
  for i = 1, #list do
    if list[i] == item then return true end
  end
  return false
end

function autogft.log(variable)
  if not env then
    env = {
      info = function(msg)
        print(msg)
      end
    }
  end

  -- Try to determine variable name
  local variableName
  local i = 1
  local var2Name, var2Val = debug.getlocal(2,1)
  while var2Name ~= nil and not variableName do
    if var2Val == variable then
      variableName = var2Name
    end
    i = i + 1
    var2Name, var2Val = debug.getlocal(2,i)
  end

  if not variableName then
    variableName = "(undefined)"
  end

  env.info(variableName .. ": " .. autogft.toString(variable))
end

function autogft.logFunction()
  local trace = "(END)"
  local i = 2
  local functionName = debug.getinfo(i, "n").name
  while functionName do
    trace = functionName .. " -> " .. trace
    i = i + 1
    functionName = debug.getinfo(i, "n").name
  end
  autogft.log("Function trace: " .. trace)
end

function autogft.getTableID(table)
  return tostring(table):sub(8)
end
