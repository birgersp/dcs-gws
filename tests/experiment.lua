
if not initialized then

  assert(loadfile([[C:\Users\Birger\Workspace\dcs-autogft\build\autogft-1_9-beta.lua]]))()

  autogft_Setup:new()
    :addBaseZone("BLUE_BASE")
    :addIntermidiateZone("CONTROL1")

  autogft_Setup:new()
    :addBaseZone("RED_BASE")
    :addIntermidiateZone("CONTROL1")
    :linkBase("RED_BASE", "BASEUNIT")

  initialized = true

end
