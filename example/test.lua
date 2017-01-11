
if not initialized then

  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\build\autogft-1_6-standalone.lua]]))()
  autogft_debugMode = true

  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\example\example-simple.lua]]))()
  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\example\example-detailed.lua]]))()

  initialized = true
end
