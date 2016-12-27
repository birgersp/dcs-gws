
if not initialized then

  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\build\autogft-standalone.lua]]))()
  autogft.debugMode = true
  
  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\build\example.lua]]))()

  initialized = true
end
