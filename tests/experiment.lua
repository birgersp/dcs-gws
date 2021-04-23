local function log(string)
  autogft.log(string)
end

local waypoints = {}
local function addWaypoint(x, y)
  waypoints[#waypoints + 1] = {
    x = x,
    y = y,
    speed = 20,
    action = "Cone"
  }
end

local function foobar()
  env.info("WAYPOINT TEST")
  local group1 = Group.getByName("Group1")
  local group1Pos = group1:getUnit(1):getPosition().p
  addWaypoint(group1Pos.x, group1Pos.z)
  addWaypoint(group1Pos.x + 2500, group1Pos.z)
  addWaypoint(group1Pos.x + 2500, group1Pos.z + 2500)
  addWaypoint(group1Pos.x, group1Pos.z + 2500)
  addWaypoint(group1Pos.x, group1Pos.z)
  local task = {
    id = "Mission",
    params = {
      route = {
        points = waypoints
      }
    }
  }
  log(group1:getController())
  group1:getController():setTask(task)
end
timer.scheduleFunction(foobar,nil,5)
