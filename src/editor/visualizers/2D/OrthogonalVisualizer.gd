extends Control

export(float) var speed: float = 1
export(float) var faster_factor: float = 5
export(float) var mouse_speed: float = 0.01

onready var camera: Camera = $ViewportContainer/Viewport/Camera
onready var camera_initial_position: Vector3 = camera.translation
var dragging: bool = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo() \
			and event.button_index == BUTTON_MIDDLE:
		dragging = true
	elif event is InputEventMouseButton and not event.is_pressed():
		dragging = false
	if dragging and event is InputEventMouseMotion:
		var factor = (faster_factor if Input.is_action_pressed("visualizer_3d_faster") else 1.0) * mouse_speed
		update_camera_position(event.relative * factor)

func _process(delta: float) -> void:
	if has_focus():
		var factor = (faster_factor if Input.is_action_pressed("visualizer_3d_faster") else 1.0) * speed * delta
		var movement = Vector2(
			Input.get_action_strength("visualizer_3d_rotate_left") - Input.get_action_strength("visualizer_3d_rotate_right"),
			Input.get_action_strength("visualizer_3d_rotate_up") - Input.get_action_strength("visualizer_3d_rotate_down")
		)
		update_camera_position(movement * factor)

func update_camera_position(pan: Vector2) -> void:
	camera.translate_object_local(Vector3(-pan.x, pan.y, 0))
