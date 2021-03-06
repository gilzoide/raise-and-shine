extends "res://editor/visualizers/VisualizerContainer.gd"

func _process(delta: float) -> void:
	if has_focus():
		var factor = (faster_factor if Input.is_action_pressed("visualizer_3d_faster") else 1.0) * speed * delta
		var movement = Vector2(
			Input.get_action_strength("visualizer_3d_rotate_left") - Input.get_action_strength("visualizer_3d_rotate_right"),
			Input.get_action_strength("visualizer_3d_rotate_up") - Input.get_action_strength("visualizer_3d_rotate_down")
		)
		update_camera_with_pan(movement * factor)

func update_camera_with_pan(pan: Vector2) -> void:
	camera.translate_object_local(Vector3(-pan.x, pan.y, 0))
