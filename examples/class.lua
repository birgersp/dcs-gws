
Mammal = autogft_Class:create()

function Mammal:new(name)
  self = Mammal:createInstance()
  self.name = name
  return self
end

function Mammal:print()
  print("Mammal name: " .. name)
end



Person = Mammal:extend()



Dog = Mammal:extend()

function Dog:new(name, owner)
  local animal = Mammal:new(name)
  self = Dog:createInstance(animal)
  self.owner = owner
  return self
end

function Dog:print()
  Mammal.print(self)
  print("Owner name: " .. self.owner.name)
end



local person = Person:new("Charlie Brown")
person:print()

local dog = Dog:new("Snoopy", person)
dog:print()
