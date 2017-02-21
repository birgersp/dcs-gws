# Autonomous Ground Force Tasking
Utility script for DCS World mission making ([download](https://github.com/birgersp/dcs-autogft/releases/latest/)).

### Project goal
This project aims to enable DCS World mission makers to easily set up dynamic battle scenarios by using zones. AI units of a task force will automatically move to capture target zones, advance through captured zones and be reinforced when taking casualties.

[(Version 1.1 demo)](https://www.youtube.com/watch?v=Cqv3Mj-Ss58)

## How it works

### Task forces
Task forces (AI units) will try to assume control of pre-defined mission trigger zones. Once the task force units has cleared a zone of enemy units, it will move to the next in the list (automatically). If any of the task force's previously controlled zones are invaded by enemies, the task force will retreat to retake that zone.

When a task force is attacked and taking casualties, it can be set to be automatically reinforced using two modes:
* Spawn new units in the base(s)
* Assume control of pre-existing units located in the base(s)

## Getting started
1. Download and unpack [the latest autogft release zip](https://github.com/birgersp/dcs-autogft/releases/latest/)  

2. Add some trigger zones to your DCS World mission  
<img src="https://cloud.githubusercontent.com/assets/5260237/21239139/ef528744-c305-11e6-9fa4-d19f45ac4b78.jpg" width="640"/>

3. Make a script (a .lua file) for your mission, the example.lua file (provided in the release zip) is a good starting point  

4. In your mission, create a mission start trigger  

5. Add two "DO SCRIPT FILE" actions to the trigger, one to load the autogft standalone (first) and another to load your mission script  
<img src="https://cloud.githubusercontent.com/assets/5260237/21239387/f762718c-c306-11e6-8f58-07480400e8fb.jpg" width="640"/>

6. Start your mission

Please note: If you want to change your mission script later, you need to reload it into your mission by clicking "open" in the do script file action and select it again. The standalone script does not have to be re-loaded.  

Use the [`unit-types.txt`](https://raw.githubusercontent.com/birgersp/dcs-unit-types/master/unit-types.txt) to view a list of available unit types

[(Outdated) Version 0.1 demo/instructional video](https://www.youtube.com/watch?v=bmTS60qrF5g)

## Documenation
- [Some example mission scripts](https://github.com/birgersp/dcs-autogft/tree/master/examples)
- [Code API](https://birgersp.github.io/dcs-autogft/)

## Planned features
See [issue list](https://github.com/birgersp/dcs-autogft/issues)

## Credits
- [MIST project](https://github.com/mrSkortch/MissionScriptingTools)
- [DCS-API](https://github.com/FlightControl-Master/DCS-API) initially written by [Sven](https://github.com/FlightControl-Master)
- [thebgpikester](https://github.com/thebgpikester) for extensive testing and support
