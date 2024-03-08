extends Node

enum PIECE {EMPTY, PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING}

class BoardRep:
	func _init():
		clear_board()
	
	func get_tile(_col: int, _row: int) -> Tile:
		assert(false)
		return null
	
	func set_tile(_col: int, _row: int, _tile: Tile) -> Tile:
		assert(false)
		return null
	
	func clear_board():
		assert(false)
	
	func setup_board():
		clear_board()
		var color = false
		for c in range(0, 2):
			set_tile(0, 0, Piece.new(PIECE.ROOK, color))
			set_tile(0, 0, Piece.new(PIECE.KNIGHT, color))
			set_tile(0, 0, Piece.new(PIECE.BISHOP, color))
			set_tile(0, 0, Piece.new(PIECE.QUEEN, color))
			set_tile(0, 0, Piece.new(PIECE.KING, color))
			set_tile(0, 0, Piece.new(PIECE.BISHOP, color))
			set_tile(0, 0, Piece.new(PIECE.KNIGHT, color))
			set_tile(0, 0, Piece.new(PIECE.ROOK, color))
			for i in range(0, 8):
				set_tile(0, 0, Piece.new(PIECE.PAWN, color))
			color = true
		
	func move(from_col: int, from_row: int, to_col: int, to_row: int):
		assert(not get_tile(from_col, from_row).is_empty())
		var piece = get_tile(from_col, from_row)
		if get_tile(to_col, to_row).is_piece():
			capture_piece(to_col, to_row)
		set_tile(from_col, from_row, Tile.new())
		set_tile(to_col, to_row, piece)
		
	func capture_piece(col: int, row: int):
		assert(not get_tile(col, row).is_empty())
		set_tile(col, row, Tile.new())
		
	func clone_board_state() -> BoardRep:
		assert(false)
		return null
	
class BoardRepArray extends BoardRep:
	var tiles: Array[Array]
		
	func clear_board():
		tiles = []
		for i in range(0, 8):
			tiles.append([])
			for j in range(0, 8):
				tiles[i].append(Tile.new())
	
	func get_tile(col: int, row: int) -> Tile:
		return tiles[col][row]
	
	func set_tile(col: int, row: int, tile: Tile) -> Tile:
		var old_tile = get_tile(col, row)
		tiles[col][row] = tile
		return old_tile
		
	func clone_board_state() -> BoardRep:
		var newBoardState: BoardRepArray = new()
		for i in range(0, 8):
			for j in range(0, 8):
				newBoardState.set_tile(i, j, get_tile(i, j).copy());
		return newBoardState

class Tile:
	func is_empty():
		return true
	
	func is_piece():
		return false
		
	func copy():
		return new()
	
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
		
	func copy():
		return new(piece_type, color)

class PieceObject extends Piece:
	var object: MeshInstance3D
	
	func _init(_type: PIECE, _color: bool, _object):
		super(_type, _color)
		assert(_object != null)
		object = _object

