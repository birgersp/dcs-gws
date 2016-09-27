---
-- @type mynamespace
mynamespace = {}

---
-- @type mynamespace.MyClass
-- @field #number var1
mynamespace.MyClass = {}

---
-- @param #number param1
-- @return #mynamespace.MyClass
function mynamespace.MyClass.new(param1)
  local self = mynamespace.MyClass
  self.var1 = param1
  return self
end


---
--
function supercoolfunc(obj)
end

























