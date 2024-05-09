extends Node3D

@export var tile_width = 3

var piece_models = [null]

signal left_clicked(col: int, row: int)
signal right_clicked(col: int, row: int)

@onready var model: ChessBoardModel = $ChessBoardModel

var _selected_tile: Vector2i

var tile_scene = preload("res://Scenes/tile.tscn")
var piece_scene = preload("res://Scenes/PieceView.tscn")
var white_mat = preload("res://Materials/ChessWhite.tres")
var black_mat = preload("res://Materials/ChessBlack.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	piece_models.append(preload("res://Models/pawn.obj"))
	piece_models.append(preload("res://Models/rook.obj"))
	piece_models.append(preload("res://Models/knight.obj"))
	piece_models.append(preload("res://Models/bishop.obj"))
	piece_models.append(preload("res://Models/queen.obj"))
	piece_models.append(preload("res://Models/king.obj"))
	
	model.piece_spawned.connect(_spawn_piece)
	
	for i in range(0, 8):
		for j in range(0, 8):
			var new_tile = tile_scene.instantiate()
			new_tile.col = i
			new_tile.row = j
			new_tile.scale = Vector3(tile_width, 1, tile_width)
			if ((i % 2) == (j % 2)):
				new_tile.material_override = black_mat
			else:
				new_tile.material_override = white_mat
			new_tile.name = str(i) + "-" + str(j)
			add_child(new_tile)
			new_tile.set_global_position(_get_tile_position(i, j))
			
	#left_clicked.connect(_select_piece)
	#right_clicked.connect(_move_selected_piece)
	
	model.setup_board()

func _get_tile_position(col: int, row: int) -> Vector3:
	return Vector3(-col*2*tile_width, 0, row*2*tile_width)

#white = False, black = True
func _spawn_piece(col: int, row: int, piece: Enums.PIECE, color: bool):
	var newPieceObject = piece_scene.instantiate()
	newPieceObject.col = col
	newPieceObject.row = row
	newPieceObject.mesh = piece_models[piece]
	newPieceObject.name = str(Enums.PIECE.keys()[piece])
	if color:
		newPieceObject.set_surface_override_material(0, black_mat)
		newPieceObject.name = "BLACK_" + newPieceObject.name
	else:
		newPieceObject.set_surface_override_material(0, white_mat)
		newPieceObject.name = "WHITE_" + newPieceObject.name
	var otherWithSameName = find_child(newPieceObject.name, false, false)
	if otherWithSameName != null:
		otherWithSameName.name += "_1"
		var i: int = 2
		while find_child(newPieceObject.name + "_" + str(i), false, false) != null:
			i += 1
		newPieceObject.name += "_" + str(i)
	add_child(newPieceObject)
	newPieceObject.set_global_position(_get_tile_position(col, row))
