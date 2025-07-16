extends TileMapLayer

## Script to paint floor and ceiling tiles on the TileMapLayer
## Attaches directly to TileMapLayer node and paints tiles once on _ready()
## Uses GameState for dynamic level dimensions

func _ready():
	print("TileMapPainter: Starting tile painting...")
	call_deferred("paint_tiles")

func paint_tiles():
	if not tile_set:
		print("TileMapPainter: ERROR - No TileSet found!")
		return
	
	# Get level dimensions from GameState
	var level_width_tiles = GameState.get_level_width_tiles()
	var level_width_pixels = GameState.get_level_width_pixels()
	
	print("TileMapPainter: Using dynamic level dimensions from GameState")
	print("TileMapPainter: Level width - ", level_width_tiles, " tiles (", level_width_pixels, " pixels)")
		
	var source_id = 0  # First source in the TileSet
	var atlas_coords = Vector2i(0, 0)  # First tile in the atlas
	var alternative_tile = 0  # Default tile alternative
	
	# Fixed tile positions
	var ceiling_y = 0
	var floor_y = 16
	
	print("TileMapPainter: Painting ceiling tiles...")
	# Paint ceiling tiles (y = 0)
	for x in range(level_width_tiles + 1):
		set_cell(Vector2i(x, ceiling_y), source_id, atlas_coords, alternative_tile)
	
	print("TileMapPainter: Painting floor tiles...")
	# Paint floor tiles (y = 16) 
	for x in range(level_width_tiles + 1):
		set_cell(Vector2i(x, floor_y), source_id, atlas_coords, alternative_tile)
		
	print("TileMapPainter: Tile painting complete!")
	print("TileMapPainter: Painted ", (level_width_tiles + 1) * 2, " tiles total") 