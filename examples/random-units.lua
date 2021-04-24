
---
-- Randomized units example
-- Using a group of 5 to 10 M-1 Abrams and 2 to 8 M-2 Bradleys
-- and another group of 0 to 5 AAA Vulcans

gws_Setup:new()
  :useRandomUnits()
  :setCountry(country.id.USA)
  :addRandomUnitAlternative(10, "M-1 Abrams", 5)
  :addRandomUnitAlternative(8, "M-2 Bradley", 2)
  :addTaskGroup()
  :addRandomUnitAlternative(5, "Vulcan", 0)
  :addBaseZone("SOME_BASE_NAME")
