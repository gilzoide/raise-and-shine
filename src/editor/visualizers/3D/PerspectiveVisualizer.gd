extends Control

export(float) var speed: float = 1
export(float) var faster_factor: float = 5
export(float) var mouse_speed: float = 0.01

onready var camera: Camera = $ViewportContainer/Viewport/Camera
onready var camera_initial_position: Vector3 = camera.translation
var dragging: bool = false
var euler_angles: Vector3 = Vector3.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo() \
			and event.button_index == BUTTON_MIDDLE:
		dragging = true
	elif event is InputEventMouseButton and not event.is_pressed():
		dragging = false
	if dragging and event is InputEventMouseMotion:
		update_orbit_camera(event.relative * mouse_speed, 0)

func _process(delta: float) -> void:
	if has_focus():
		var factor = (faster_factor if Input.is_action_pressed("visualizer_3d_faster") else 1.0) * speed * delta
		var movement = Vector2(
			Input.get_action_strength("visualizer_3d_rotate_right") - Input.get_action_strength("visualizer_3d_rotate_left"),
			Input.get_action_strength("visualizer_3d_rotate_up") - Input.get_action_strength("visualizer_3d_rotate_down")
		)
		var clockwise = Input.get_action_strength("visualizer_3d_rotate_clockwise") - Input.get_action_strength("visualizer_3d_rotate_counterclockwise")
		update_orbit_camera(movement * factor, clockwise * factor)

func update_orbit_camera(pan: Vector2, angle: float) -> void:
	var pan3d = Vector3(-pan.x, pan.y, 0)
	var panned: Vector3 = camera.transform.xform(pan3d)
	var position = panned.normalized() * camera.translation.length()
	var up = camera.transform.basis.xform(Vector3.UP).rotated(Vector3.FORWARD, -angle)
	camera.look_at_from_position(position, Vector3.ZERO, up)
