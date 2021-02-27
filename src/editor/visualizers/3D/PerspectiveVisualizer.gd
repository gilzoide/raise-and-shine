extends Control

export(float) var speed: float = 60
export(float) var faster_factor: float = 5

var dragging = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo() \
			and event.button_index == BUTTON_MIDDLE:
		dragging = true
	elif event is InputEventMouseButton and not event.is_pressed():
		dragging = false
	if dragging and event is InputEventMouseMotion:
		PhotoBooth.rotate_plate_mouse(event.relative)

func _process(delta: float) -> void:
	if has_focus():
		var factor = (faster_factor if Input.is_action_pressed("visualizer_3d_faster") else 1.0) * speed * delta
		var movement = Vector2(
			Input.get_action_strength("visualizer_3d_rotate_left") - Input.get_action_strength("visualizer_3d_rotate_right"),
			Input.get_action_strength("visualizer_3d_rotate_up") - Input.get_action_strength("visualizer_3d_rotate_down")
		)
		var clockwise = Input.get_action_strength("visualizer_3d_rotate_clockwise") - Input.get_action_strength("visualizer_3d_rotate_counterclockwise")
		PhotoBooth.rotate_plate(movement * factor, clockwise * factor)
