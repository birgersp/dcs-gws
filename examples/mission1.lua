-- Mission initialization
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

  -- Reinforcement setups
  reinforcementSetups = {
    bajas.ReinforcementSetup.new("BMP-3", 3, country.id.USA, "spawnB1", "defenceB1"),
    bajas.ReinforcementSetup.new("BRDM-2", 2, country.id.USA, "spawnB1", "defenceB1"),
    bajas.ReinforcementSetup.new("LAV-25", 4, country.id.USA, "spawnB1", "defenceB1") ,
    bajas.ReinforcementSetup.new("BMP-3", 3, country.id.USA, "spawnB2", "defenceB2"),
    bajas.ReinforcementSetup.new("BRDM-2", 2, country.id.USA, "spawnB2", "defenceB2"),
    bajas.ReinforcementSetup.new("LAV-25", 4, country.id.USA, "spawnB2", "defenceB2"),
    bajas.ReinforcementSetup.new("M-1 Abrams", 3, country.id.USA, "spawnB2", "defenceB2"),
    bajas.ReinforcementSetup.new("BMP-3", 3, country.id.RUSSIA, "spawnR1", "defenceR1"),
    bajas.ReinforcementSetup.new("BRDM-2", 2, country.id.RUSSIA, "spawnR1", "defenceR1"),
    bajas.ReinforcementSetup.new("BTR-80", 4, country.id.RUSSIA, "spawnR1", "defenceR1"),
    bajas.ReinforcementSetup.new("BMP-3", 3, country.id.RUSSIA, "spawnR2", "defenceR2"),
    bajas.ReinforcementSetup.new("BRDM-2", 2, country.id.RUSSIA, "spawnR2", "defenceR2"),
    bajas.ReinforcementSetup.new("BTR-80", 4, country.id.RUSSIA, "spawnR2", "defenceR2"),
    bajas.ReinforcementSetup.new("T-72B", 3, country.id.RUSSIA, "spawnR2", "defenceR2")
  }

  for i=1, #reinforcementSetups do
    bajas.registerReinforcementSetup(reinforcementSetups[i], minReinforcementTime)
  end

end
