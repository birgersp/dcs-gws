
if not initialized then
  autogft.debugMode = true


  autogft.TaskForce
    :new(country.id.USA, {"SPAWN1", "SPAWN2"}, {"Combat1", "Combat2", "Combat3"})
    :addUnitSpec(4, "M-1 Abrams")
    :addUnitSpec(4, "M-1 Abrams")
    :addUnitSpec(4, "LAV-25")
    :respawn()
    :enableObjectiveUpdateTimer(120)
    :enableRespawnTimer(300, 1200)

  autogft.TaskForce
    :new(country.id.RUSSIA, {"SPAWN3"}, {"Combat3", "Combat2", "Combat1"})
    :addUnitSpec(4, "T-90")
    :respawn()
    :enableObjectiveUpdateTimer(120)
    :enableRespawnTimer(300)

  autogft.TaskForce
    :new(country.id.RUSSIA, {"Combat2"}, {"Combat2"})
    :addUnitSpec(2, "BMP-2")
    :respawn()
    :enableObjectiveUpdateTimer(250)
    :enableRespawnTimer(120, 600)


  autogft.enableIOCEV()
  initialized = true
end
