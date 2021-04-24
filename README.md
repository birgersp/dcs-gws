# Autonomous Ground Force Tasking
Utility script for DCS World mission making ([download](https://github.com/birgersp/dcs-autogft/releases/latest/)).

## Project goal
This project aims to enable DCS World mission makers to easily set up dynamic battle scenarios by using zones. AI units of a task force will automatically move to capture target zones, advance through captured zones and be reinforced when taking casualties.

[(Version 1.1 demo)](https://www.youtube.com/watch?v=Cqv3Mj-Ss58)

## Getting started
1. Download [the latest autogft release zip](https://github.com/birgersp/dcs-autogft/releases/latest/) and unzip it 

2. Add some trigger zones to your mission, these can act as "bases" or "objectives" 

3. Put some AI units in your bases
<img src="http://i.imgur.com/GuYEOLj.jpg"/>

4. Create a new script (a ".lua" file) for your mission

```
-- (example mission script)

-- BLUE UNITS
autogft_Setup:new()
  :addBaseZone("BLUE_BASE")
  :addControlZone("OBJECTIVE_WEST")
  :addControlZone("OBJECTIVE_EAST")

-- RED UNITS
autogft_Setup:new()
  :addBaseZone("RED_BASE")
  :addControlZone("OBJECTIVE_EAST")
  :addControlZone("OBJECTIVE_WEST")
```

5. Create a mission start trigger in the mission editor 

6. Add two "DO SCRIPT FILE" actions to the trigger, one to load the autogft script (first) and another to load your mission script
<img src="http://i.imgur.com/8enqsoo.jpg"/>

7. The mission is ready to start. Following the example here, the red and blue units will battle in the objective zones. Dead groups will respawn in the base zones. 

Please note: If you want to change your mission script later, you need to reload it into your mission by clicking "open" in the do script file action and select it again. 

## Documenation
- [Example mission scripts](https://github.com/birgersp/dcs-autogft/tree/master/examples)
- [Code API](https://birgersp.github.io/dcs-autogft/api/Setup.html)
- [(Outdated) Version 0.1 demo/instructional video](https://www.youtube.com/watch?v=bmTS60qrF5g)

## Planned features
See [issue list](https://github.com/birgersp/dcs-autogft/issues)

## Develop/experimenting
This project can be imported into LuaDevelopmentTools. It should automatically execute the compilation script whenever you save a change to the source files.

If you prefer not to use LuaDevelopmentTools, follow these steps to compile the source files:
1. Open a Command Prompt terminal (`cmd.exe`)
2. Change directory to the project (use the command `cd C:\MyLuaProjects\dcs-autogft`)
3. Execute the command `batch/make.cmd`

Once the source files have been compiled, you should see a `build` and a `build-test` folder in the project.

During compilation, the source files are merged to a single script. In addition, a "load experiment" script is also generated. Load this script into your mission:
1. Create or open your DCS World mission with the Mission Editor
2. Add a trigger: MISSION START
3. Add an action: DO SCRIPT
4. In the DO SCRIPT text, add `dofile("C:\\MyLuaProjects\\dcs-autogft\\build-test\\load-experiment.lua")`
5. Save the mission
6. Click "FLIGHT" and then "PREPARE MISSION"
7. The mission will start (you might get an error when the mission starts, depending on what's in the `tests\experiment.lua` script but ignore that for now)

Now you can minimize DCS World, edit the source files (located in the `autogft` folder), and do some experiments/testing with the `tests\experiment.lua` file. Once the code with your experiment is ready for another test, re-compile it (happens automatically when saving in LuaDevelopmentTools, or see the steps above) and restart the mission (press SHIFT+R).

If you want to make a pull request, please use the same commit message and code style as the rest of the project. Please refer to the issue that the commit is regarding.

## Credits
- [DCS-API](https://github.com/FlightControl-Master/DCS-API) initially written by [Sven](https://github.com/FlightControl-Master)
- [thebgpikester](https://github.com/thebgpikester)
- [DCS Community](https://forums.eagle.ru/showthread.php?t=179522)
- [132nd Virtual Wing](http://www.132virtualwing.org/)
- [jkhoel](https://github.com/jkhoel)
