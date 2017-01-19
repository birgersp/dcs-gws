
---
-- Showing how to use class emulation
-- (Do not distribute in autogft release)



package.path = package.path .. ";../autogft/?.lua"
require("class")



---
-- @type Mammal
-- @extends Class#Class
-- @field #string name
Mammal = autogft_Class:create()

---
-- @param #Mammal self
-- @param #string name
-- @return #Mammal
function Mammal:new(name)
  self = Mammal:createInstance()
  self.name = name
  return self
end

---
-- @param #Mammal self
function Mammal:print()
  print("Mammal name: " .. self.name)
end



---
-- @type Person
-- @extends #Mammal
Person = Mammal:extend()



---
-- @type Dog
-- @extends #Mammal
Dog = Mammal:extend()

---
-- @param #Dog self
-- @field #string name
-- @field #Person owner
function Dog:new(name, owner)
  local animal = Mammal:new(name)
  self = Dog:createInstance(animal)
  self.owner = owner
  return self
end

---
-- @param #Dog self
function Dog:print()
  Mammal.print(self)
  print("Owner name: " .. self.owner.name)
end



local function test()
  local person = Person:new("Charlie Brown")
  person:print()

  local dog = Dog:new("Snoopy", person)
  dog:print()
end
test()
