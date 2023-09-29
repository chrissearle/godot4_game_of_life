extends TileMap

const TILE_SIZE := 128

@export var width: int
@export var height: int

@onready var cam = $Camera2D
@onready var timer := $Timer

var playing := false

var new_field = []

func _ready() -> void:
	randomize()
	
	var width_px = width * TILE_SIZE
	var height_px = height * TILE_SIZE
	
	cam.position = Vector2(width_px, height_px) / 2
	cam.zoom = Vector2(1920, 1080) / Vector2(width_px, height_px)
	
	for x in range(width):
		var new_row = []

		for y in range(height):
			new_row.append(false)
		
		new_field.append(new_row)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("randomize"):
		randomize_map()

	if event.is_action_pressed("toggle_play"):
		playing = !playing
		
		if playing:
			timer.start()
		
	if event.is_action_pressed("click"):
		var cell_coord = local_to_map(get_local_mouse_position())
		
		if has_cell(cell_coord):
			remove_cell(cell_coord)
		else:
			add_cell(cell_coord)

func update_field():
	for x in range(width):
		for y in range(height):
			var live_neighbours = count_surrounding_cells(Vector2i(x, y))
			
			if has_cell(Vector2i(x, y)):
				new_field[x][y] = live_neighbours in [2, 3]
			else:
				new_field[x][y] = live_neighbours == 3

func update_tilemap_from_field():
	for x in range(width):
		for y in range(height):
			var cell_coord = Vector2i(x, y)
			
			if new_field[x][y]:
				if !has_cell(cell_coord):
					add_cell(cell_coord)
			else:
				if has_cell(cell_coord):
					remove_cell(cell_coord)

func count_surrounding_cells(cell_coord: Vector2i) -> int:
	var cells : Array[Vector2i]= []

	for i in range(cell_coord.x - 1, cell_coord.x + 2):
		for j in range(cell_coord.y - 1, cell_coord.y + 2):
			var cell = Vector2i(i, j)

			if cell != cell_coord:
				if has_cell(cell):
					cells.append(cell)

	return cells.size()

func add_cell(cell_coord: Vector2i):
	set_cell(0, cell_coord, 1, Vector2i(0, 0))

func remove_cell(cell_coord: Vector2i):
	erase_cell(0, cell_coord)

func has_cell(cell_coord: Vector2i) -> bool:
	return get_cell_tile_data(0, cell_coord) != null

func randomize_map():
	if playing:
		timer.stop()
		playing = false
	
	var threshold = randi() % 10
	
	for x in range(width):
		for y in range(height):
			var cell_coord = Vector2i(x, y)

			remove_cell(cell_coord)
			
			if randi() % 20 < threshold:
				add_cell(cell_coord)

func _on_timer_timeout() -> void:
	if playing:
		update_field()
		update_tilemap_from_field()
		timer.start()
