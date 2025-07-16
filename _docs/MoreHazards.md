
Guidance to Keep in Mind:
Goal: We want a single Spike.tscn that can be configured to be any of the four spike types.
Mechanism: Use an @export enum in the script to create a dropdown in the Inspector.
Action: The script's _ready() function will read the chosen enum value and set the correct texture and collision shape size.

The Prompt to Give Cursor:
"I need to refactor my Spike.tscn to handle all four of my spike textures (spike_bottom.png, spike_top.png, and their large versions) in a single, reusable scene.

1. Modify scripts/hazards/spike.gd:
    At the top of the script, create an enum called SpikeType with four values: BOTTOM, TOP, BOTTOM_LARGE, TOP_LARGE.
    Create a new @export var type: SpikeType variable.
    Get @onready references to the Sprite2D and CollisionShape2D nodes.
    In the _ready() function, create a match statement that checks the value of the type variable.
    Inside the match statement:
    For each SpikeType, set the Sprite2D.texture to the correct preloaded png file from assets/sprites/hazards/.
    For each SpikeType, also resize the CollisionShape2D. The standard spikes should have a collision size of (64, 64). Assume the large spikes should have a size of (128, 64).

2. Modify scenes/levels/level_1.tscn:
    Triple the level's TileMapLayer width and move the RightWall.
    Create a Node2D named Hazards to hold all the spike instances.
    Inside Hazards, create a long row of three instances of Spike.tscn. For each one, select it and set its Type in the Inspector to BOTTOM_LARGE. Position them starting at (2000, 950).
    Create another row of two instances of Spike.tscn. Set their Type to BOTTOM in the Inspector. Position them starting at (2800, 950).
    Create a row of two instances of Spike.tscn. Set their Type to TOP in the Inspector. Position them starting at (2400, 150)."