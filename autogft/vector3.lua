---
-- @module Vector3

---
-- @type Vector3
-- @extends class#Class
-- @extends DCSVec3#Vec3
autogft_Vector3 = autogft_Class:create()

---
-- @param #Vector3 self
-- @return #Vector3
function autogft_Vector3:new(x, y, z)
  self = self:createInstance()
  self.x = x
  self.y = y
  self.z = z
  return self
end

---
-- @param #Vector3 self
-- @return #Vector3
function autogft_Vector3:getCopy()
  return self:new(self.x, self.y, self.z)
end

---
-- @param #Vector3 self
-- @param #Vector3 vector
function autogft_Vector3:add(vector)
  self.x = self.x + vector.x
  self.y = self.y + vector.y
  self.z = self.z + vector.z
end

---
-- @param #Vector3 self
-- @param #number factor
function autogft_Vector3:scale(factor)
  self.x = self.x * factor
  self.y = self.y * factor
  self.z = self.z * factor
end

---
-- @param #Vector3 self
function autogft_Vector3:normalize()
  self:scale(1 / self:getMagnitude())
end

---
-- @param #Vector3 self
-- @param #Vector3 vector
-- @return #number
function autogft_Vector3:getDotProduct(vector)
  return self.x * vector.x + self.y * vector.y + self.z * vector.z
end

---
-- @param #Vector3 self
-- @param #Vector3 vector
-- @return #Vector3
function autogft_Vector3:getCrossProduct(vector)
  local x = self.y * vector.z - self.z * vector.y
  local y = self.z * vector.x - self.x * vector.z
  local z = self.x * vector.y - self.y * vector.x
  return autogft_Vector3:new(x, y, z)
end

---
-- @param #Vector3 self
-- @return #number
function autogft_Vector3:getMagnitude()
  return math.sqrt(self.x^2 + self.y^2 + self.z^2)
end

---
-- @param #Vector3 self
-- @param #Vector3 vector
-- @param #Vector3 plane (Optional)
-- @return #number
function autogft_Vector3:getAngleTo(vector, plane)
  local cosine = self:getDotProduct(vector) / (self:getMagnitude() * vector:getMagnitude())
  local angle = math.acos(cosine)
  if plane then
    local cross = self:getCrossProduct(vector)
    if plane:getDotProduct(cross) < 0 then
      angle = -angle
    end
  end
  return angle
end

---
-- @type Vector3.Axis
-- @field #Vector3 X
-- @field #Vector3 Y
-- @field #Vector3 Z
autogft_Vector3.Axis = {
  X = autogft_Vector3:new(1, 0, 0),
  Y = autogft_Vector3:new(0, 1, 0),
  Z = autogft_Vector3:new(0, 0, 1)
}
