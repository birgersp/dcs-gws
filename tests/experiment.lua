
if not initialized then

  assert(loadfile([[C:\Users\Birger\Workspace\dcs-autogft\build\autogft-1_9-beta.lua]]))()

  autogft_Setup:new()
    :useRandomUnits()
    :addRandomUnitAlternative(12, unitType.vehicle.unarmed.Tigr_233036, 4)
    :addBaseZone("RED_BASE")
    :addControlZone("CONTROL1")
    :setCountry(country.id.RUSSIA)

  initialized = true

end
