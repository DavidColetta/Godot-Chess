extends Area3D

signal left_clicked
signal right_clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _mouse_enter():
	#print("Mouse enter")
	pass

func _input_event(camera, event, mouse_position, normal, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		if event.get_button_index() == MOUSE_BUTTON_LEFT:
			print("Clicked "+get_parent().name)
			left_clicked.emit()
		elif event.get_button_index() == MOUSE_BUTTON_RIGHT:
			print("Right clicked "+get_parent().name)
			right_clicked.emit()
