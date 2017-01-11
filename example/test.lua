
if not initialized then

  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\build\autogft-1_6_SNAP-standalone.lua]]))()
  autogft_debugMode = true

  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\example\example-simple.lua]]))()

  initialized = true
end
