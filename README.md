# Autonomous Ground Force Tasking
Utility script for DCS World mission making

[Demo/instructional video](https://www.youtube.com/watch?v=bmTS60qrF5g)

## Current features

### Task forces
With this feature, ground AI units may be set to try to assume control of pre-defined mission trigger zones. Once the task force units has cleared a zone of enemy units, it will move to the next in the list (automatically). If any of the task force's previously controlled zones are invaded by enemies, the task force will retreat to retake the zone.

Task forces may be set to be automatically reinforced, by respawning units and rejoining them with the rest of the task force.

This feature is meant to provide mission makers with an easy way to create dynamic ground battle scenarios.

### Intel on close ground units
Gives each player (client) in the mission the ability to get direction and distance to enemy ground units. Ideal when players want a simple way to find enemy ground targets for A/G practice.

## How to use
(Tip: The demo video will show how steps 2-5 are performed)

1. Download and unpack [the latest release zip](https://github.com/birgersp/dcs-autogft/releases)
2. (For the ground force tasking system) Add some trigger zones to your DCS World mission
3. Make a script (a .lua file) for your mission, use the example provided to get started
4. In your mission, create a mission start trigger
5. Add two "DO SCRIPT FILE" actions to the trigger, one to load the autogft standalone (first) and another to load your mission script
6. If you want to change your mission script later, you need to reload it into your mission by clicking "open" in the do script file action and select it again

Use the `unit-types.txt` to view a list of available unit types
