class_name ChessBoardModel
extends Node

var board: Array[Array]

var piece_scenes: Array[PackedScene] = [null]

signal piece_spawned
signal piece_captured
signal piece_moved

# Called when the node enters the scene tree for the first time.
func _ready():
	piece_scenes.append(preload("res://Scenes/pawn.tscn"))
	piece_scenes.append(preload("res://Scenes/rook.tscn"))
	piece_scenes.append(preload("res://Scenes/knight.tscn"))
	piece_scenes.append(preload("res://Scenes/bishop.tscn"))
	piece_scenes.append(preload("res://Scenes/queen.tscn"))
	piece_scenes.append(preload("res://Scenes/king.tscn"))
	
	for i in range(0, 8):
		board.append([])
		for j in range(0, 8):
			board[i].append(null)

func get_tile(col: int, row: int) -> Piece:
	return board[col][row]
	
#sets the board tile at c-r to piece object (can be null)
func _set_tile(col: int, row: int, tile: Piece):
	board[col][row] = tile
	if tile:
		tile.col = col
		tile.row = row
		
func capture_piece(piece):
	_set_tile(piece.col, piece.row, null)
	piece.queue_free()
	piece_captured.emit()

func move_piece(piece: Piece, target_col: int, target_row: int):
	pass

##white = False, black = True
func spawn_piece(col: int, row: int, piece: Enums.PIECE, color: bool):
	var newPiece = piece_scenes[piece].instantiate()
	newPiece.color = color
	newPiece.col = col
	newPiece.row = row
	newPiece.name = str(Enums.PIECE.keys()[piece])
	if color:
		newPiece.name = "BLACK_" + newPiece.name
	else:
		newPiece.name = "WHITE_" + newPiece.name
	var otherWithSameName = find_child(newPiece.name, false, false)
	if otherWithSameName != null:
		otherWithSameName.name += "_1"
		var i: int = 2
		while find_child(newPiece.name + "_" + str(i), false, false) != null:
			i += 1
		newPiece.name += "_" + str(i)
	_set_tile(col, row, newPiece)
	add_child(newPiece)
	piece_spawned.emit(col, row, piece, color)

func _setup_board_for_color(color: bool):
	spawn_piece(0, int(color) * 7, Enums.PIECE.ROOK, color)
	spawn_piece(1, int(color) * 7, Enums.PIECE.KNIGHT, color)
	spawn_piece(2, int(color) * 7, Enums.PIECE.BISHOP, color)
	spawn_piece(3, int(color) * 7, Enums.PIECE.QUEEN, color)
	spawn_piece(4, int(color) * 7, Enums.PIECE.KING, color)
	spawn_piece(5, int(color) * 7, Enums.PIECE.BISHOP, color)
	spawn_piece(6, int(color) * 7, Enums.PIECE.KNIGHT, color)
	spawn_piece(7, int(color) * 7, Enums.PIECE.ROOK, color)
	
	for i in range(0, 8):
		spawn_piece(i, 1 + (int(color) * 5), Enums.PIECE.PAWN, color)

func setup_board():
	_setup_board_for_color(false)
	_setup_board_for_color(true)
