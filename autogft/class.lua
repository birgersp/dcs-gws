
---
-- Class emulation.
-- @module Class

---
-- A template for creating autogft objects.
-- @type Class
autogft_Class = {}

---
-- Creates a new class.
-- @param #Class self
-- @return #Class
function autogft_Class:create()
  return setmetatable({}, {__index = autogft_Class})
end

---
-- Creates a subclass of this class.
-- @param #Class self
-- @return #Class
function autogft_Class:extend()
  local class = autogft_Class:create()
  setmetatable(class, {__index = self})
  return class
end

---
-- Instantiates this class.
-- Do not override this function (see @{#Class.new}).
-- @param #Class self
-- @param #table superObject (Optional) Parent object which the new instance will inherit attributes from
-- @return #table
function autogft_Class:createInstance(superObject)
  local instance = setmetatable({}, {__index = self})
  if superObject then
    for key, value in pairs(superObject) do
      instance[key] = value
    end
  end
  return instance
end

---
-- Instanties this class.
-- Override this function to create a custom constructor.
-- @param #Class self
-- @return #table
function autogft_Class:new()
  return self:createInstance(nil)
end

---
-- Returns wether this object is a type or subtype of a class.
-- @param #Class self
-- @return #boolean
function autogft_Class:instanceOf(class)

  local result = false
  local superClass
  local metatable = getmetatable(self)

  while metatable and not result do
    superClass = metatable.__index
    if superClass == class then
      result = true
    end
    metatable = getmetatable(superClass)
  end

  return result
end
