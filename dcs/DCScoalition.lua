-------------------------------------------------------------------------------
-- @module DCScoalition

--- @type coalition
-- @field #coalition.side side

--- @type coalition.side
-- @field NEUTRAL
-- @field RED
-- @field BLUE

--- @function [parent=#coalition] getCountryCoalition
-- @param #number countryId
-- @return #number coalitionId

---
-- Returns a table of group objects belonging to the specified coalition.
-- If the groupCategory enumerator is provided the table will only contain groups that belong to the specified category.
-- If this optional variable is not provided, all group types will be returned.
-- @function [parent=#coalition] getGroups
-- @param #number coalitionId, #number groupCategory
-- @return #list<DCSGroup#Group>

---
-- Returns a table of unit objects that are currently occupied by players. Function is useful in multiplayer to easily filter client aircraft from everything else.
-- @function [parent=#coalition] getPlayers
-- @param #number coalitionId
-- @return #list<DCSUnit#Unit>

coalition = {} --#coalition
