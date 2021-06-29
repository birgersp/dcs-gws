
---
-- Ground Warfare Script basic example
-- https://github.com/birgersp/dcs-autogft
--
-- Lines beginning with "--" are comments and does not affect the code
-- Put the standalone script and this script in "do script file" actions in a mission start trigger
-- Remember to re-load this script to your mission after you have edited it, it is not necessary to re-load the standalone
-- Comments above code blocks explain what the code is doing



--- 
-- (BLUE TASK FORCE)
-- Adding base zone(s)
-- Adding control zone(s)

gws_Setup:new()
  :addBaseZone("BLUE_BASE1")
  :addControlZone("CONTROL1")
  :addControlZone("CONTROL2")
  :addControlZone("CONTROL5")


--- 
-- (RED TASK FORCE)

gws_Setup:new()
  :addBaseZone("RED_BASE")
  :addControlZone("CONTROL5")
  :addControlZone("CONTROL2")
  :addControlZone("CONTROL1")
  