extends Node3D
var tile_scene = preload("res://tile.tscn")
var white_mat = preload("res://ChessWhite.tres")
var black_mat = preload("res://ChessBlack.tres")
@export var tile_width = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(1, 9):
		for j in range(1, 9):
			var new_tile = tile_scene.instantiate()
			
			new_tile.set_global_position(Vector3(i*2*tile_width, 0, j*2*tile_width))
			new_tile.scale = Vector3(tile_width, 1, tile_width)
			if ((i % 2) == (j % 2)):
				new_tile.material_override = black_mat
			else:
				new_tile.material_override = white_mat
			add_child(new_tile)
			new_tile.name = str(i) + "-" + str(j)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
