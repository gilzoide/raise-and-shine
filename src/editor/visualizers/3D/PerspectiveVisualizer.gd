extends Control

export(float) var speed: float = 1
export(float) var faster_factor: float = 5
export(float) var mouse_speed: float = 0.01

onready var viewport: Viewport = $ViewportContainer/Viewport
onready var camera: Camera = $ViewportContainer/Viewport/Camera
onready var camera_initial_transform: Transform = camera.transform
var dragging: bool = false

func _ready() -> void:
	var _err = PhotoBooth.connect("drag_started", self, "set_default_cursor_shape", [Control.CURSOR_VSIZE])
	_err = PhotoBooth.connect("drag_ended", self, "set_default_cursor_shape", [Control.CURSOR_ARROW])

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo() \
			and event.button_index == BUTTON_MIDDLE:
		dragging = true
		grab_focus()
	elif event is InputEventMouseButton and not event.is_pressed():
		dragging = false
	if dragging and event is InputEventMouseMotion:
		var factor = (faster_factor if Input.is_action_pressed("visualizer_3d_faster") else 1.0) * mouse_speed
		update_orbit_camera(event.relative * factor, 0)
	elif event.is_action_pressed("visualizer_reset"):
		camera.transform = camera_initial_transform
	else:
		viewport.unhandled_input(event)

func _process(delta: float) -> void:
	if has_focus():
		var factor = (faster_factor if Input.is_action_pressed("visualizer_3d_faster") else 1.0) * delta
		var movement = Vector2(
			Input.get_action_strength("visualizer_3d_rotate_left") - Input.get_action_strength("visualizer_3d_rotate_right"),
			Input.get_action_strength("visualizer_3d_rotate_up") - Input.get_action_strength("visualizer_3d_rotate_down")
		)
		var clockwise = Input.get_action_strength("visualizer_3d_rotate_clockwise") - Input.get_action_strength("visualizer_3d_rotate_counterclockwise")
		update_orbit_camera(movement * speed * factor, clockwise * factor)

func update_orbit_camera(pan: Vector2, angle: float) -> void:
	var pan3d = Vector3(-pan.x, pan.y, 0)
	var panned: Vector3 = camera.transform.xform(pan3d)
	var position = panned.normalized() * camera.translation.length()
	var up = camera.transform.basis.xform(Vector3.UP).rotated(Vector3.FORWARD, -angle)
	camera.look_at_from_position(position, Vector3.ZERO, up)
