
if not initialized then

  assert(loadfile([[C:\Users\Birger\Workspace\dcs-autogft\build\autogft-1_9-beta.lua]]))()

  autogft_Setup:new()
    :addBaseZone("BLUE_BASE3")
    :addControlZone("CONTROL1")
    :addControlZone("CONTROL2")
    :addControlZone("CONTROL3")
    :setAdvancementTimer(60)

  initialized = true

end
