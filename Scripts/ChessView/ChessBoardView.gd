extends Node3D

@export var tile_width = 3

var piece_models = [null]

signal left_clicked(col: int, row: int)
signal right_clicked(col: int, row: int)

@onready var model: ChessBoardModel = $ChessBoardModel as ChessBoardModel

var _selected_tile: Vector2i
var board: Array[Array]

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
	
	for i in range(0, 8):
		board.append([])
		for j in range(0, 8):
			board[i].append(null)
			var new_tile = tile_scene.instantiate()
			new_tile.col = i
			new_tile.row = j
			new_tile.scale = Vector3(tile_width, 1, tile_width)
			if ((i % 2) == (j % 2)):
				new_tile.material_override = black_mat
			else:
				new_tile.material_override = white_mat
			new_tile.name = str(i) + "-" + str(j)
			new_tile.chess_board_view = self
			add_child(new_tile)
			new_tile.set_global_position(_get_tile_position(i, j))
			
	model.piece_spawned.connect(_spawn_piece)
	model.piece_captured.connect(_despawn_piece)
	model.piece_moved.connect(_move_piece)
	
	left_clicked.connect(_select_piece)
	right_clicked.connect(_move_selected_piece)
	
func start_game():
	model.setup_board()

func _select_piece(col: int, row: int):
	_selected_tile = Vector2i(col, row)
	
func _move_selected_piece(col: int, row: int):
	if _selected_tile.x < 0: return
	if col == _selected_tile.x and row == _selected_tile.y: return
	if board[_selected_tile.x][_selected_tile.y] == null: return
	model.move_piece(_selected_tile.x, _selected_tile.y, col, row)
	_selected_tile = Vector2i(-1, -1)

func _get_tile_position(col: int, row: int) -> Vector3:
	return Vector3(-col*2*tile_width, 0, row*2*tile_width)

#white = False, black = True
func _spawn_piece(col: int, row: int, piece: Enums.PIECE, color: Enums.COLOR):
	var newPieceObject = piece_scene.instantiate()
	board[col][row] = newPieceObject
	newPieceObject.mesh = piece_models[piece]
	newPieceObject.create_trimesh_collision()
	newPieceObject.name = str(Enums.PIECE.keys()[piece])
	if color == Enums.COLOR.BLACK:
		newPieceObject.rotate_y(deg_to_rad(90.0))
		newPieceObject.set_surface_override_material(0, black_mat)
		newPieceObject.name = "BLACK_" + newPieceObject.name
	else:
		newPieceObject.rotate_y(deg_to_rad(-90.0))
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

func _despawn_piece(col: int, row: int):
	var piece = board[col][row]
	piece.queue_free()
	board[col][row] = null

func _move_piece(col: int, row: int, target_col: int, target_row: int):
	var piece = board[col][row]
	piece.set_global_position(_get_tile_position(target_col, target_row))
	board[target_col][target_row] = piece
	board[col][row] = null
