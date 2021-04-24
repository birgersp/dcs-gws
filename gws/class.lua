---
-- @module Class

---
-- A template for creating gws objects.
-- @type Class
gws_Class = {}

---
-- Creates a new class.
-- @param #Class self
-- @return #Class
function gws_Class:create()
  return setmetatable({}, {__index = gws_Class})
end

---
-- Creates a subclass of this class.
-- @param #Class self
-- @return #Class
function gws_Class:extend()
  local class = gws_Class:create()
  setmetatable(class, {__index = self})
  return class
end

---
-- Instantiates this class.
-- Do not override this function (see @{#Class.new}).
-- @param #Class self
-- @param #table superObject (Optional) Parent object which the new instance will inherit attributes from
-- @return #table
function gws_Class:createInstance(superObject)
  local instance = setmetatable({}, {__index = self})

  -- Automatically invoke super-constructor if no superobject is provided
  if not superObject then
    local metatable = getmetatable(self)
    if metatable and metatable ~= gws_Class then
      superObject = metatable.__index:new()
    end
  end

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
function gws_Class:new()
  return self:createInstance(nil)
end

---
-- Returns wether this object is a type or subtype of a class.
-- @param #Class self
-- @return #boolean
function gws_Class:instanceOf(class)

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

---
-- Throws an error with the message that an abstract function was invoked.
-- The name of the function invoking this function will be included in the message.
-- @param #Class self
function gws_Class:throwAbstractFunctionError()
  local functionName = debug.getinfo(2, "n").name
  error("Abstract function \"" .. functionName .. "\" invoked.")
end

---
-- Compares each field of this object the each field of another, and returns whether the fields are identical.
-- @param #Class self
-- @return #boolean
function gws_Class:equals(object)
  for key, value in pairs(object) do
    if self[key] ~= value then
      return false
    end
  end
  return true
end
