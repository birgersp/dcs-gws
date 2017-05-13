
---
-- Linked bases example
-- Base zone "BASE1" will be linked to the group "BASE1_BUILDINGS"
-- When (if) the units (buildings) in BASE1_BUILDINGS group are destroyed, the base zone "BASE1" will be disabled and units won't spawn there anymore
-- Note that this only applies for the task force/setup where this is enabled. Other task forces/setup will still use the base zone

autogft_Setup:new()
  :addBaseZone("BASE1")
  :linkBase("BASE1", "BASE1_BUILDINGS")
  :addControlZone("SOME_CONTROL_ZONE")
