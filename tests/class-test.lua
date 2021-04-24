
package.path = package.path .. ";../gws/?.lua"
require("class")



---
-- @type Mammal
-- @extends class#Class
-- @field #string name
Mammal = gws_Class:create()

---
-- @param #Mammal self
-- @param #string name
-- @return #Mammal
function Mammal:new(name)
  self = self:createInstance()
  self.name = name
  return self
end

---
-- @param #Mammal self
function Mammal:print()
  print("Mammal name: " .. self.name)
end

---
-- @param #Mammal self
function Mammal:abstractFunc()
  self:throwAbstractFunctionError()
end



---
-- @type Person
-- @extends #Mammal
Person = Mammal:extend()

function Person:abstractFunc()
  print("Hello from function overriding abstractFunc")
end



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
  self = self:createInstance(animal)
  self.owner = owner
  return self
end

---
-- @param #Dog self
function Dog:print()
  Mammal.print(self)
  print("Owner name: " .. self.owner.name)
end



---
-- @type Vehicle
-- @extends class#Class
-- @field #number someAttribute
Vehicle = gws_Class:create()

---
-- @param #Vehicle self
-- @return #Vehicle
function Vehicle:new()
  self = self:createInstance()
  self.someAttribute = 123
  return self
end



---
-- @type Car
-- @extends #Vehicle
Car = Vehicle:extend()

---
-- @param #Car self
-- @return #Car
function Car:new()
  self = self:createInstance()
  return self
end



local function test()
  local whale = Mammal:new("Tugger")

  local person = Person:new("Charlie Brown")
  person:print()
  person:abstractFunc()

  local dog = Dog:new("Snoopy", person)
  dog:print()

  local car = Car:new()
  local vehicle = Vehicle:new()
  print("Car", car.someAttribute)
  print("Vehicle", vehicle.someAttribute)
end
test()
