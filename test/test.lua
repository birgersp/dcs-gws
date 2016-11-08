
if not initialized then

  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\build\autogft-standalone.lua]]))()
  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\build\example.lua]]))()
  autogft.debugMode = true

  initialized = true
end
