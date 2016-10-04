-- Mission initialization
if (initialized == nil or initialized == false) then
  
  local MIN_REINFORCEMENT_T = 1800
  local MIN_ADVANCEMENT_TIME = 600

  -- Some type names:
  -- BRDM-2
  -- BMP-3
  -- T-55
  -- T-72B
  -- T-90

  -- M-1 Abrams
  -- Leopard-2
  
  local taskForce1 = bajas.TaskForce:new(country.id.USA,"task1",{"task2", "task3"})
  taskForce1:addUnitSpec(3, bajas.unitTypes.vehicles.Tanks.M1_Abrams)
  taskForce1:addUnitSpec(3, bajas.unitTypes.vehicles.IFV.LAV25)
  taskForce1:reinforce()
  
  local taskForce2 = bajas.TaskForce:new(country.id.USA,"task1",{"task2", "task3"})
  taskForce1:addUnitSpec(3, bajas.unitTypes.vehicles.Tanks.M1_Abrams)
  taskForce1:addUnitSpec(3, bajas.unitTypes.vehicles.IFV.LAV25)
  taskForce1:reinforce() 
  
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
end
