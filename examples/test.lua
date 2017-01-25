
if not initialized then

  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\build\autogft-1_7-standalone.lua]]))()
  autogft.debugMode = true

  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\examples\basic.lua]]))()
  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\examples\miscellaneous.lua]]))()
  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\examples\reinforcing.lua]]))()
  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\examples\scanning.lua]]))()
  assert(loadfile([[C:\Users\birge\Workspace\dcs-autogft\examples\using-roads.lua]]))()

  initialized = true

end
