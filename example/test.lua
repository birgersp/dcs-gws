
if not initialized then

  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\build\autogft-1_6_SNAP-standalone.lua]]))()
  autogft_debugMode = true
  
  -- assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\build\example.lua]]))()

  autogft_TaskForce:new()
    :setCountry(country.id.USA)
    :addBaseZone("SPAWN1")
    :addControlZone("Combat1")
    :addControlZone("Combat3")
    :addGroup(2, "M-1 Abrams")
    :respawn()
    :setAdvancementTimer(300)
    :setRespawnTimer(120)

  initialized = true
end
