
if not initialized then

  dofile("C:\\Users\\birge\\repo\\dcs-autogft\\tests\\load-all.lua")

  autogft_Setup:new()
  :addBaseZone("BLUE_BASE")
  :setReinforceTimerMax(1200)
  :addControlZone("OBJECTIVE_WEST")

  initialized = true

end
