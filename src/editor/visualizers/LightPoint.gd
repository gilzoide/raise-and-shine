extends CollisionObject

onready var light = $SpotLight
onready var sphere = $SphereMesh
var dragging: bool = false

func _input_event(camera: Object, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			dragging = event.is_pressed()
		elif event.button_index == BUTTON_RIGHT and event.is_pressed() and not event.is_echo():
			var position = get_tree().root.get_viewport().get_mouse_position()
			LightEditorPopup.popup_at(position, light.light_color, funcref(self, "set_light_color"))
	elif dragging and event is InputEventMouseMotion:
		var position_in_xy = Plane.PLANE_XY.intersects_ray(
			camera.project_ray_origin(event.position),
			camera.project_ray_normal(event.position)
		)
		if position_in_xy:
			translation = position_in_xy

func set_light_color(color: Color) -> void:
	light.light_color = color
	sphere.material_override.albedo_color = color
