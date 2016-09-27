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
                str = str .. " = " .. toStringRecursively(value, level + 1)
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
            end
        end

        return str
    end

    return toStringRecursively(obj, 1)
end


bsputil.ReinforcementSetup = function(unitType, unitCount, country, spawnName, destinationName)
    return {
        unitType = unitType,
        unitCount = unitCount,
        country = country,
        spawnName = spawnName,
        destinationName = destinationName
    }
end

function bsputil.reinforce(reinforcementSetup, unitCount)

    local units = {}
    for i = 1, unitCount do
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

-- Check if
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
            bsputil.reinforce(setup, reinforcementCount)
        end
    end
end