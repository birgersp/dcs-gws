
if not initialized then

  assert(loadfile([[C:\Users\Birger\Workspace\dcs-autogft\build\autogft-1_9-beta.lua]]))()

  autogft_Setup:new()
    :addBaseZone("BLUE_BASE3")
    :addIntermidiateZone("CONTROL1")
    :addIntermidiateZone("CONTROL2")
    :addIntermidiateZone("CONTROL3")

  initialized = true

end
