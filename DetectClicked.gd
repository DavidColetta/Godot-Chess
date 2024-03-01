extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _mouse_enter():
	print("Mouse enter")

func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and event.get_button_index() == 1:
		print("Clicked "+get_parent().name)
