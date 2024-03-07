extends Node3D
var tile_scene = preload("res://tile.tscn")
var piece_scene = preload("res://piece.tscn")
var white_mat = preload("res://ChessWhite.tres")
var black_mat = preload("res://ChessBlack.tres")

var piece_models = [null]

signal left_clicked(col: int, row: int)
signal right_clicked(col: int, row: int)

@export var tile_width = 3

var board: Chess.BoardRep

var _selected_tile: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	piece_models.append(preload("res://Models/Pawn.tres"))
	piece_models.append(preload("res://Models/Rook.tres"))
	piece_models.append(preload("res://Models/Knight.tres"))
	piece_models.append(preload("res://Models/Bishop.tres"))
	piece_models.append(preload("res://Models/Queen.tres"))
	piece_models.append(preload("res://Models/King.tres"))
	
	board = Chess.BoardRepArray.new()
	
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
			
	_setup_board(false)
	_setup_board(true)
	left_clicked.connect(_select_piece)
	right_clicked.connect(_move_selected_piece)
	
func _get_tile_position(col: int, row: int) -> Vector3:
	return Vector3(-col*2*tile_width, 0, row*2*tile_width)

#white = False, black = True
func _spawn_piece(col: int, row: int, piece: Chess.PIECE, color: bool):
	if color: #Invert row if black
		row = 7 - row
	
	var newPieceObject = piece_scene.instantiate()
	var newPiece = Chess.PieceObject.new(piece, color, newPieceObject)
	board.set_tile(col, row, newPiece)
	newPieceObject.mesh = piece_models[piece]
	newPieceObject.name = str(Chess.PIECE.keys()[piece])
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

func _setup_board(color: bool):
	_spawn_piece(0, 0, Chess.PIECE.ROOK, color)
	_spawn_piece(1, 0, Chess.PIECE.KNIGHT, color)
	_spawn_piece(2, 0, Chess.PIECE.BISHOP, color)
	_spawn_piece(3, 0, Chess.PIECE.QUEEN, color)
	_spawn_piece(4, 0, Chess.PIECE.KING, color)
	_spawn_piece(5, 0, Chess.PIECE.BISHOP, color)
	_spawn_piece(6, 0, Chess.PIECE.KNIGHT, color)
	_spawn_piece(7, 0, Chess.PIECE.ROOK, color)
	for i in range(0, 8):
		_spawn_piece(i, 1, Chess.PIECE.PAWN, color)

func _select_piece(col: int, row: int):
	print(col, row)
	_selected_tile = Vector2i(col, row)
	
func _move_selected_piece(col: int, row: int):
	if _selected_tile and board.get_tile(_selected_tile.x, _selected_tile.y).is_piece():
		_move(_selected_tile.x, _selected_tile.y, col, row)
	else:
		print("No Selected Piece")

func _move (from_col: int, from_row: int, to_col: int, to_row: int):
	board.get_tile(from_col, from_row).object.set_global_position(_get_tile_position(to_col, to_row))
	if board.get_tile(to_col, to_row).is_piece():
		_capture_piece(to_col, to_row)
	board.move(from_col, from_row, to_col, to_row)

func _capture_piece(col: int, row: int):
	board.get_tile(col, row).object.queue_free()
	board.capture_piece(col, row)
	
	
func copy_board_state(boardState) -> Array[Array]:
	var newBoardState: Array[Array] = []
	for i in range(0, 8):
		newBoardState.append([])
		for j in range(0, 8):
			newBoardState.append(boardState[i][j].copy());
	return newBoardState
	
