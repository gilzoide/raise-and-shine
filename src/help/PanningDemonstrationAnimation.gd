extends Control

export(float) var animation_duration = 3
export(float, 0, 1) var radius_percent = 0.7

var _timer = 0
onready var _visualizer = $OrthogonalVisualizer
onready var _cursor_icon = $CursorIcon


func _ready() -> void:
	set_process(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			_visualizer.reset_camera()
			_update_cursor_angle()
		set_process(visible)
	elif what == NOTIFICATION_RESIZED:
		_update_cursor_angle()


func _process(delta: float) -> void:
	_timer += delta
	if _timer >= animation_duration:
		_timer = fmod(_timer, animation_duration)
	
	var previous_position = _cursor_icon.position
	_update_cursor_angle()
	var current_position = _cursor_icon.position
	_visualizer.pan_by_mouse(current_position - previous_position)


func _position_for_angle(angle: float) -> float:
	var center = rect_size * 0.5
	var min_size = min(center.x, center.y)
	var delta_length = radius_percent * min_size
	return center + Vector2(delta_length, 0).rotated(angle)


func _update_cursor_angle() -> void:
	var angle = (_timer / animation_duration) * TAU
	var position = _position_for_angle(angle)
	_cursor_icon.position = position
