
if not initialized then

  dofile("C:\\Users\\Birger\\Workspace\\dcs-autogft\\tests\\version.lua")
  dofile("C:\\Users\\Birger\\Workspace\\dcs-autogft\\build\\autogft-" .. autogft_VERSION .. ".lua")

  autogft_Setup:new()
    :addBaseZone("BASE")
    :addControlZone("TARGET")
    :scanUnits("GROUP")

  initialized = true

end
