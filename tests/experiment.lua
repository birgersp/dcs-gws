--autogft_Setup:new()
--  :addBaseZone("BLUE_BASE")
--  :addControlZone("CONTROL1")


local function go()
  local groups = coalition.getGroups(coalition.side.BLUE)
  autogft.log(groups)
  local group = groups[1]
  local dcsTask = {
    id = "Mission",
    params = {
      route = {
        points = {
          [1] = {
            y = 0,
            x = 0,
            action = "Cone",
            speed = 10,
            type = "Turning Point"
          }
        }
      }
    }
  }
  autogft.log(group)
  local controller = group:getController()
  autogft.log(controller)
  controller:setTask(dcsTask)
end

autogft.scheduleFunction(go, 3)
