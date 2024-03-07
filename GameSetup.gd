extends Node3D
var tile_scene = preload("res://tile.tscn")
var piece_scene = preload("res://piece.tscn")
var white_mat = preload("res://ChessWhite.tres")
var black_mat = preload("res://ChessBlack.tres")

enum PIECE {EMPTY, PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING}

var piece_models = [null]

signal left_clicked(col: int, row: int)
signal right_clicked(col: int, row: int)

@export var tile_width = 3

var board: Array[Array] = []

var _selected_tile: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	piece_models.append(preload("res://Models/Pawn.tres"))
	piece_models.append(preload("res://Models/Rook.tres"))
	piece_models.append(preload("res://Models/Knight.tres"))
	piece_models.append(preload("res://Models/Bishop.tres"))
	piece_models.append(preload("res://Models/Queen.tres"))
	piece_models.append(preload("res://Models/King.tres"))
	
	for i in range(0, 8):
		board.append([])
		for j in range(0, 8):
			var new_tile = tile_scene.instantiate()
			new_tile.col = i
			new_tile.row = j
			board[i].append(Tile.new())
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
func _spawn_piece(col: int, row: int, piece: PIECE, color: bool):
	if color: #Invert row if black
		row = 7 - row
	
	var newPiece = PieceObject.new(piece, color)
	var newPieceObject = piece_scene.instantiate()
	newPiece.object = newPieceObject
	board[col][row] = newPiece
	newPieceObject.mesh = piece_models[piece]
	newPieceObject.name = str(PIECE.keys()[piece])
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
	_spawn_piece(0, 0, PIECE.ROOK, color)
	_spawn_piece(1, 0, PIECE.KNIGHT, color)
	_spawn_piece(2, 0, PIECE.BISHOP, color)
	_spawn_piece(3, 0, PIECE.QUEEN, color)
	_spawn_piece(4, 0, PIECE.KING, color)
	_spawn_piece(5, 0, PIECE.BISHOP, color)
	_spawn_piece(6, 0, PIECE.KNIGHT, color)
	_spawn_piece(7, 0, PIECE.ROOK, color)
	for i in range(0, 8):
		_spawn_piece(i, 1, PIECE.PAWN, color)

func _select_piece(col: int, row: int):
	print(col, row)
	_selected_tile = Vector2i(col, row)
	
func _move_selected_piece(col: int, row: int):
	if _selected_tile and board[_selected_tile.x][_selected_tile.y].is_piece():
		_move(_selected_tile.x, _selected_tile.y, col, row)
	else:
		print("No Selected Piece")

func _move (from_col: int, from_row: int, to_col: int, to_row: int):
	board[from_col][from_row].object.set_global_position(_get_tile_position(to_col, to_row))
	if board[to_col][to_row].is_piece():
		board[to_col][to_row].object.queue_free()
	_move_noanim(board, from_col, from_row, to_col, to_row)

func _move_noanim(boardState, from_col: int, from_row: int, to_col: int, to_row: int):
	assert(not boardState[from_col][from_row].is_empty())
	var piece = boardState[from_col][from_row]
	if boardState[to_col][to_row].is_piece():
		_capture_piece_noanim(boardState, to_col, to_row)
	boardState[from_col][from_row] = Tile.new()
	boardState[to_col][to_row] = piece

func _capture_piece(col: int, row: int):
	_capture_piece_noanim(board, col, row)
	board[col][row].queue_free()

func _capture_piece_noanim(boardState, col: int, row: int):
	assert(not boardState[col][row].is_empty())
	boardState[col][row] = Tile.new()

class Tile:
	func is_empty():
		return true
	
	func is_piece():
		return false
	
class Piece extends Tile:
	var color: bool
	var piece_type: PIECE

	func _init(_type: PIECE, _color: bool):
		assert(_type != PIECE.EMPTY)
		piece_type = _type
		color = _color
		
	func is_empty():
		return false
	
	func is_piece():
		return true

class PieceObject extends Piece:
	var object = null
