---
-- @module Vector2

---
-- @type Vector2
-- @extends class#Class
autogft_Vector2 = autogft_Class:create()

---
-- @param #Vector2 self
-- @return #Vector2
function autogft_Vector2:new(x, y)
  self = self:createInstance()
  self.x = x
  self.y = y
  return self
end

---
-- @param #Vector2 self
-- @param #Vector2 vector
-- @return #number
function autogft_Vector2:getCrossProduct(vector)
  return self.x * vector.y - self.y * vector.x
end

---
-- @param #Vector2 self
-- @param #Vector2 vector
-- @return #Vector2
function autogft_Vector2:getDotProduct(vector)
  return self.x * vector.x + self.y * vector.y
end

---
-- @param #Vector2 self
-- @param #Vector2 vector
-- @return #Vector2
function autogft_Vector2:getAngleTo(vector)
  local cosine = self:getDotProduct(vector) / (self:getMagnitude() * vector:getMagnitude())
  local angle = math.acos(cosine)
  if self:getCrossProduct(vector) < 0 then
    angle = math.pi * 2 - angle
  end
  return angle
end

---
-- @param #Vector2 self
-- @param #Vector2 vector
-- @return #Vector2
function autogft_Vector2:add(vector)
  self.x = self.x + vector.x
  self.y = self.y + vector.y
  return self
end

---
-- @param #Vector2 self
-- @param #number factor
-- @return #Vector2
function autogft_Vector2:scale(factor)
  self.x = self.x * factor
  self.y = self.y * factor
  return self
end

---
-- @param #Vector2 self
-- @return #Vector2
function autogft_Vector2:getMagnitude()
  return math.sqrt(self.x^2 + self.y^2)
end

---
-- @param #Vector2 self
-- @return #Vector2
function autogft_Vector2:normalize()
  return self:scale(1 / self:getMagnitude())
end

---
-- @param #Vector2 self
-- @param #Vector2 vector
-- @return #Vector2
function autogft_Vector2:plus(vector)
  return autogft_Vector2:new(self.x, self.y):add(vector)
end

---
-- @param #Vector2 self
-- @param #number factor
-- @return #Vector2
function autogft_Vector2:times(factor)
  return autogft_Vector2:new(self.x, self.y):scale(factor)
end

---
-- @param #Vector2 self
-- @return #Vector2
function autogft_Vector2:getCopy()
  return autogft_Vector2:new(self.x, self.y)
end

---
-- @param #Vector2 self
-- @param #Vector2 vector
-- @return #Vector2
function autogft_Vector2:minus(vector)
  return autogft_Vector2:new(self.x, self.y):add(vector:times(-1))
end

---
-- @type Vector2.Axis
-- @field #Vector2 X
-- @field #Vector2 Y
autogft_Vector2.Axis = {
  X = autogft_Vector2:new(1, 0),
  Y = autogft_Vector2:new(0, 1)
}
