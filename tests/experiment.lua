
if not initialized then

  dofile("C:\\Users\\Birger\\Workspace\\dcs-autogft\\tests\\load-all.lua")

  autogft_Setup:new()
    :useStaging()
    :addBaseZone("BASE")
    :addControlZone("TARGET")
    :scanUnits("GROUP1")

  autogft_Setup:new()
    :useStaging()
    :addBaseZone("BASE")
    :addControlZone("TARGET")
    :scanUnits("GROUP2")

  initialized = true

end
