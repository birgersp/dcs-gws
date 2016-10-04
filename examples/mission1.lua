-- Mission initialization

bajas.debug = true

local MIN_REINFORCEMENT_T = 1800
local MIN_ADVANCEMENT_TIME = 600

local taskForce1 = bajas.TaskForce:new(country.id.USA,"spawnB21",{"taskZone2", "taskZone3", "taskZone4", "taskZone5"})
taskForce1:addUnitSpec(12, bajas.unitTypes.vehicles.IFV.MCV80)
taskForce1:addUnitSpec(12, bajas.unitTypes.vehicles.IFV.MCV80)
taskForce1:addUnitSpec(6, bajas.unitTypes.vehicles.Tanks.Challenger2)

local taskForce2 = bajas.TaskForce:new(country.id.RUSSIA,"spawnR21",{"taskZone4", "taskZone3","taskZone2", "taskZone1"})
taskForce2:addUnitSpec(10, bajas.unitTypes.vehicles.IFV.MTLB)
taskForce2:addUnitSpec(10, bajas.unitTypes.vehicles.IFV.MTLB)
taskForce2:addUnitSpec(10, bajas.unitTypes.vehicles.IFV.MTLB)
taskForce2:addUnitSpec(10, bajas.unitTypes.vehicles.Tanks.T72B)

local function advance()
  taskForce1:advance()
  taskForce2:advance()
end

local function reinforce()
  taskForce1:reinforce()
  taskForce2:reinforce()
end

mist.scheduleFunction(reinforce, nil, timer.getTime()+1, MIN_REINFORCEMENT_T)
mist.scheduleFunction(advance, nil, timer.getTime()+5, MIN_ADVANCEMENT_TIME)

bajas.enableIOCEVForGroups()

initialized = true
