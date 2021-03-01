extends CollisionObject

var dragging: bool = false

func _input_event(camera: Object, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		dragging = event.is_pressed()
	elif dragging and event is InputEventMouseMotion:
		var position_in_xy = Plane.PLANE_XY.intersects_ray(
			camera.project_ray_origin(event.position),
			camera.project_ray_normal(event.position)
		)
		if position_in_xy:
			translation = position_in_xy
