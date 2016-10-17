
if not initialized then

  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\build\autogft-standalone.lua]]))()
  autogft.debugMode = true

  autogft.TaskForce
    :new(country.id.USA, {"SPAWN1", "SPAWN2"}, {"Combat1", "Combat2", "Combat3"})
    :addUnitSpec(4, "M-1 Abrams")
    :addUnitSpec(4, "M-1 Abrams")
    :addUnitSpec(4, "LAV-25")
    :respawn()
    :enableObjectiveUpdateTimer(120)
    :enableRespawnTimer(300)


  autogft.TaskForce
    :new(country.id.RUSSIA, {"SPAWN3"}, {"Combat3", "Combat2", "Combat1"})
    :addUnitSpec(4, "T-90")
    :respawn()
    :enableObjectiveUpdateTimer(120)
    :enableRespawnTimer(300)

  autogft.enableIOCEV()

  autogft.log("initialized");
  initialized = true
end
