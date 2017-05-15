
if not initialized then

  dofile("C:\\Users\\Birger\\Workspace\\dcs-autogft\\tests\\version.lua")
  dofile("C:\\Users\\Birger\\Workspace\\dcs-autogft\\build\\autogft-" .. autogft_VERSION .. ".lua")

  dofile("C:\\Users\\Birger\\Workspace\\dcs-autogft\\examples\\basic.lua")
  dofile("C:\\Users\\Birger\\Workspace\\dcs-autogft\\examples\\miscellaneous.lua")
  dofile("C:\\Users\\Birger\\Workspace\\dcs-autogft\\examples\\scanning.lua")
  dofile("C:\\Users\\Birger\\Workspace\\dcs-autogft\\examples\\staging.lua")
  dofile("C:\\Users\\Birger\\Workspace\\dcs-autogft\\examples\\using-roads.lua")

  initialized = true

end
