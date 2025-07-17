

I want the strucutre of the spikes to be refactored to match the style of the Platform.md

Example:
Baseplatform.tscn
    Woodblock.tscn
    WoodPlatform.tscn
    WoodPlatformsmall.tscn


Refactor

Refactoring Spikes with Scene Inheritance

Part A
1:
    Purify the "Brain" - Create BaseSpike.tscn
    We will turn your existing Spike.tscn into a pure logic scene that will serve as the template for all other spikes.
    1. Rename the Core Files:
    In the FileSystem dock, rename scenes/hazards/Spike.tscn to BaseSpike.tscn.
    Rename scripts/hazards/spike.gd to base_spike.gd. Godot will ask if you want to update dependencies; click Yes.

2. Strip the Visuals from the Base Scene:
    Open your newly renamed BaseSpike.tscn.
    In the Scene dock, delete the Sprite2D node.
    Also delete the CollisionShape2D node.
    Your BaseSpike.tscn should now only contain the root Area2D node with the base_spike.gd script attached.

3. Clean Up the Base Script:
    Open base_spike.gd. We need to remove all the code that was responsible for changing the visuals.
    Delete the entire enum SpikeType { ... } block.
    Delete the line @export var type: SpikeType = SpikeType.BOTTOM.
    Delete the @onready variables for the sprite and collision_shape.
    Delete the entire _configure_spike_type() function.
    Your _ready() function should now be very simple. 
    Save BaseSpike.tscn and base_spike.gd. You now have a perfect, reusable "brain" for all your hazards.


Part B

1. 
    Create SpikeBottomStandard.tscn:
    Go to Scene -> New Inherited Scene... and select BaseSpike.tscn.
    Add a Sprite2D node and set its texture to bottom_spike.png.
    Add a CollisionShape2D node, give it a RectangleShape2D, and resize it to fit the standard spike.
    Save this new scene as SpikeBottomStandard.tscn in scenes/hazards/.
2. 
    Create SpikeTopStandard.tscn:
    Create another inherited scene from BaseSpike.tscn.
    Add a Sprite2D with the top_spike.png texture.
    Add a CollisionShape2D with a RectangleShape2D sized to fit.
    Save as SpikeTopStandard.tscn.
3. 
    Create SpikeBottomLarge.tscn:
    Create another inherited scene from BaseSpike.tscn.
    Add a Sprite2D with the spikes_large_bottom.png texture.
    Add a CollisionShape2D with a RectangleShape2D. Resize the collision shape to be larger, matching the large sprite.
    Save as SpikeBottomLarge.tscn.
4. 
    Create SpikeTopLarge.tscn:
    Create one final inherited scene from BaseSpike.tscn.
    Add a Sprite2D with the spikes_large_top.png texture.
    Add a CollisionShape2D with a larger RectangleShape2D.
    Save as SpikeTopLarge.tscn.


Part C
    "Open scenes/levels/level_1.tscn.
    Under the Hazards node, delete all existing spike instances.
    Now, add new instances using the inherited scenes from the scenes/hazards/ folder:
    Create a row of three instances of SpikeBottomLarge.tscn starting at position (2000, 950).
    Create a row of two instances of SpikeBottomStandard.tscn starting at (2800, 950).
    Create a row of two instances of SpikeTopStandard.tscn starting at (2400, 150)."