extends MeshInstance3D

var col: int
var row: int

# Called when the node enters the scene tree for the first time.
func _ready():
	var click_detector = $StaticBody3D
	if click_detector:
		click_detector.left_clicked.connect(_on_left_clicked)
		click_detector.right_clicked.connect(_on_right_clicked)

func _on_left_clicked():
	GameSetup.left_clicked.emit(col, row)

func _on_right_clicked():
	GameSetup.right_clicked.emit(col, row)
