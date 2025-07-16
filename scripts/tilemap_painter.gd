extends TileMapLayer

## Script to paint floor and ceiling tiles on the TileMapLayer
## Attaches directly to TileMapLayer node and paints tiles once on _ready()

func _ready():
	print("TileMapPainter: Starting tile painting...")
	call_deferred("paint_tiles")

func paint_tiles():
	if not tile_set:
		print("TileMapPainter: ERROR - No TileSet found!")
		return
		
	var source_id = 0  # First source in the TileSet
	var atlas_coords = Vector2i(0, 0)  # First tile in the atlas
	var alternative_tile = 0  # Default tile alternative
	
	# Level dimensions for scrolling
	var level_width = 60  # tiles wide (60 * 64 = 3840 pixels)
	var ceiling_y = 0
	var floor_y = 16
	
	print("TileMapPainter: Painting ceiling tiles...")
	# Paint ceiling tiles (y = 0)
	for x in range(level_width + 1):
		set_cell(Vector2i(x, ceiling_y), source_id, atlas_coords, alternative_tile)
	
	print("TileMapPainter: Painting floor tiles...")
	# Paint floor tiles (y = 16) 
	for x in range(level_width + 1):
		set_cell(Vector2i(x, floor_y), source_id, atlas_coords, alternative_tile)
		
	print("TileMapPainter: Tile painting complete!")
	print("TileMapPainter: Painted ", (level_width + 1) * 2, " tiles total") 