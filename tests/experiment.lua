
if not initialized then

  dofile("C:\\Users\\Birger\\Workspace\\dcs-autogft\\tests\\load-all.lua")

  autogft_Setup:new()
    :addBaseZone("MAIN_BASE")
    :addControlZone("F_BASE1")
    :copyGroupsLayout("GROUP1")

  autogft_Setup:new()
    :addBaseZone("MAIN_BASE")
    :addControlZone("F_BASE2")
    :copyGroupsLayout("GROUP2")

  autogft_Setup:new()
    :useStaging()
    :addBaseZone("F_BASE1")
    :addControlZone("COMBAT")
    :scanUnits("GROUP1")

  autogft_Setup:new()
    :useStaging()
    :addBaseZone("F_BASE2")
    :addControlZone("COMBAT")
    :scanUnits("GROUP2")

  initialized = true

end
