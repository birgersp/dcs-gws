
if not initialized then
  autogft.debugMode = true


  local usTaskForce = autogft.TaskForce:new(
    country.id.USA, {"SPAWN1", "SPAWN2"}, {"Combat1", "Combat2", "Combat3"})
  usTaskForce:addUnitSpec(4, "M-1 Abrams")
  usTaskForce:addUnitSpec(4, "M-1 Abrams")
  usTaskForce:addUnitSpec(4, "LAV-25")
  usTaskForce:respawn()
  usTaskForce:enableObjectiveUpdateTimer(120)
  usTaskForce:enableRespawnTimer(300, 1200)
  
  local russiaTaskForce1 = autogft.TaskForce:new(
    country.id.RUSSIA, {"SPAWN3"}, {"Combat3", "Combat2", "Combat1"})
  russiaTaskForce1:addUnitSpec(4, "T-90")
  russiaTaskForce1:respawn()
  russiaTaskForce1:enableObjectiveUpdateTimer(120)
  russiaTaskForce1:enableRespawnTimer(300)
  
  local russiaTaskForce2 = autogft.TaskForce:new(
    country.id.RUSSIA, {"Combat2"}, {"Combat2"})
  russiaTaskForce2:addUnitSpec(2, "BMP-2")
  russiaTaskForce2:respawn()
  russiaTaskForce2:enableObjectiveUpdateTimer(250)
  russiaTaskForce2:enableRespawnTimer(120, 600)


  autogft.enableIOCEV()
  initialized = true
end
