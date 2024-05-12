extends Node3D


const RAY_LENGTH = 1000

func _physics_process(_delta):
	if get_parent().playerID != multiplayer.get_unique_id(): return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		raycast_for_tile(MOUSE_BUTTON_LEFT)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		raycast_for_tile(MOUSE_BUTTON_RIGHT)

func raycast_for_tile(mouse_button: int):
	var space_state = get_world_3d().direct_space_state
	var cam = $Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	if result.has("collider"):
#			print(result["collider"].get_parent())
		var target = result["collider"].get_parent()
		if mouse_button == MOUSE_BUTTON_LEFT and target.has_method("on_left_clicked"):
			target.on_left_clicked()
		elif mouse_button == MOUSE_BUTTON_RIGHT and target.has_method("on_right_clicked"):
			target.on_right_clicked()
