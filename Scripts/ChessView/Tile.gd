extends MeshInstance3D

var chess_board_view
var col: int
var row: int

func on_left_clicked():
	print("Left clicked "+name)
	chess_board_view.left_clicked.emit(col, row)

func on_right_clicked():
	print("Right clicked "+name)
	chess_board_view.right_clicked.emit(col, row)
