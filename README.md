# Autonomous Ground Force Tasking
Utility script for DCS World mission making

## Current features

### Task forces
With this feature, ground AI units may be set to try to assume control of pre-defined mission trigger zones. Once the task force units has cleared a zone of enemy units, it will move to the next in the list (automatically). If any of the task force's previously controlled zones are invaded by enemies, the task force will retreat to retake the zone.

Task forces may be set to be automatically reinforced by two modes

#### Re-spawning
Automatically re-spawn units from base zones and reinforce task force

#### Re-staging
Automatically assume control of units located in the base and reinfroce task force

This feature is meant to provide mission makers with an easy way to create dynamic ground battle scenarios.

### Intel on close ground units
Gives each player (client) in the mission the ability to get direction and distance to enemy ground units. Ideal when players want a simple way to find enemy ground targets for A/G practice.

## How to use
(Tip: The demo video will show how steps 2-5 are performed)

1. Download and unpack [the latest autogft release zip](https://github.com/birgersp/dcs-autogft/releases/latest/)  
2. Add some trigger zones to your DCS World mission  
<img src="https://cloud.githubusercontent.com/assets/5260237/21239139/ef528744-c305-11e6-9fa4-d19f45ac4b78.jpg" width="640"/>
3. Make a script (a .lua file) for your mission, use the example provided to get started  
4. In your mission, create a mission start trigger  
5. Add two "DO SCRIPT FILE" actions to the trigger, one to load the autogft standalone (first) and another to load your mission script  
<img src="https://cloud.githubusercontent.com/assets/5260237/21239387/f762718c-c306-11e6-8f58-07480400e8fb.jpg" width="640"/>
6. If you want to change your mission script later, you need to reload it into your mission by clicking "open" in the do script file action and select it again  
<img src="https://cloud.githubusercontent.com/assets/5260237/21239238/4ea96f3c-c306-11e6-9cc8-38d8360fcccc.jpg" width="640"/>

Use the `unit-types.txt` to view a list of available unit types

[(Outdated) Version 0.1 demo/instructional video](https://www.youtube.com/watch?v=bmTS60qrF5g)
