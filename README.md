# DCS-BAJAS
Birger And Jens' Asset Script for DCS mission making

## Current features

### Task forces
With this feature, ground AI units may be set to try to assume control of pre-defined mission zones. Once the task force units has cleared a control zone of enemy units, it will move to the next in the list (automatically). If any of the task force's previously controlled zones are invaded by enemies, the task force will retreat to retake the control point.

Task forces may be set to be automatically reinforced, by respawning units and rejoining them with the rest of the task force.

This feature provides mission makers with an easy way to create dynamic ground battle scenarios.

Check out our [demo video](https://www.youtube.com/watch?v=bmTS60qrF5g)

### Intel on close ground units
Gives each player (client) in the mission the ability to get direction and distance to enemy ground units. Ideal when players want a simple way to find enemy ground targets for A/G practice.

## Planned features

### Aircraft balancing
Spawns AI aircrafts to join the battle when there is an imbalance between REDFOR and BLUEFOR aircrafts. Useful when you want to keep air-to-air battle somewhat balanced.

## How to use in your mission
1. Add a mission start trigger
2. Add a do script action, loading the `bajas-standalone.lua` file
3. Add another do script action, loading your own script to utilize our script

(More details coming soon)
