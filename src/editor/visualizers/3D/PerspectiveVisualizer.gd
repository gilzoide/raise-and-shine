extends "res://editor/visualizers/VisualizerContainer.gd"

export(float) var min_zoom_distance: float = 128
export(float) var max_zoom_distance: float = 4

func _process(delta: float) -> void:
	if has_focus():
		var factor = (faster_factor if Input.is_action_pressed("visualizer_3d_faster") else 1.0) * delta
		var movement = Vector2(
			Input.get_action_strength("visualizer_3d_rotate_left") - Input.get_action_strength("visualizer_3d_rotate_right"),
			Input.get_action_strength("visualizer_3d_rotate_up") - Input.get_action_strength("visualizer_3d_rotate_down")
		)
		var clockwise = Input.get_action_strength("visualizer_3d_rotate_clockwise") - Input.get_action_strength("visualizer_3d_rotate_counterclockwise")
		update_camera_with_pan(movement * speed * factor, clockwise * factor)

func update_camera_with_pan(pan: Vector2, angle: float = 0) -> void:
	var pan3d = Vector3(-pan.x, pan.y, 0)
	var panned: Vector3 = camera.transform.xform(pan3d)
	var position = panned.normalized() * camera.translation.length()
	var up = camera.transform.basis.xform(Vector3.UP).rotated(Vector3.FORWARD, -angle)
	camera.look_at_from_position(position, Vector3.ZERO, up)

func set_camera_zoom_percent(percent: float) -> void:
	var direction = camera.translation.normalized()
	camera.translation = direction * lerp(min_zoom_distance, max_zoom_distance, percent)
