-- Initialization
--initialized = false
if (initialized == nil or initialized == false) then
    lastCreatedUnitId = 0
    lastCreatedGroupId = 0

    upTime = 0
    prevReinforcementTime = 0
    minReinforcementTime = 1200

    -- Some type names:
    -- BRDM-2
    -- BMP-3
    -- T-55
    -- T-72B
    -- T-90

    -- M-1 Abrams
    -- Leopard-2
    reinforcementSetups = {
        -- Blue reinforcements
        bsputil.ReinforcementSetup("BMP-3", 3, country.id.USA, "spawnB1", "defenceB1"),
        bsputil.ReinforcementSetup("BRDM-2", 2, country.id.USA, "spawnB1", "defenceB1"),
        bsputil.ReinforcementSetup("LAV-25", 4, country.id.USA, "spawnB1", "defenceB1"),

        bsputil.ReinforcementSetup("BMP-3", 3, country.id.USA, "spawnB2", "defenceB2"),
        bsputil.ReinforcementSetup("BRDM-2", 2, country.id.USA, "spawnB2", "defenceB2"),
        bsputil.ReinforcementSetup("LAV-25", 4, country.id.USA, "spawnB2", "defenceB2"),
        bsputil.ReinforcementSetup("M-1 Abrams", 3, country.id.USA, "spawnB2", "defenceB2"),

        -- Red reinforcements
        bsputil.ReinforcementSetup("BMP-3", 3, country.id.RUSSIA, "spawnR1", "defenceR1"),
        bsputil.ReinforcementSetup("BRDM-2", 2, country.id.RUSSIA, "spawnR1", "defenceR1"),
        bsputil.ReinforcementSetup("BTR-80", 4, country.id.RUSSIA, "spawnR1", "defenceR1"),

        bsputil.ReinforcementSetup("BMP-3", 3, country.id.RUSSIA, "spawnR2", "defenceR2"),
        bsputil.ReinforcementSetup("BRDM-2", 2, country.id.RUSSIA, "spawnR2", "defenceR2"),
        bsputil.ReinforcementSetup("BTR-80", 4, country.id.RUSSIA, "spawnR2", "defenceR2"),
        bsputil.ReinforcementSetup("T-72B", 3, country.id.RUSSIA, "spawnR2", "defenceR2")
    }

    initialized = true
end


-- Each timestep
if (upTime - prevReinforcementTime >= minReinforcementTime or upTime == 0) then
    bsputil.checkAndReinforce(reinforcementSetups)
    prevReinforcementTime = upTime
end
upTime = upTime + 1
























