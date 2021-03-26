extends Control

export(float) var animation_duration = 5
export(float) var animation_delay = 1

var _speed = 1
var _timer = 0
onready var _visualizer = $OrthogonalVisualizer


func _ready() -> void:
	set_process(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			_timer = 0
			_speed = 1
			_visualizer.reset_camera()
		set_process(visible)


func _process(delta: float) -> void:
	_timer += _speed * delta
	if _timer >= animation_duration + animation_delay or _timer <= -animation_delay:
		_speed = -_speed
		_timer = clamp(_timer, -animation_delay, animation_duration + animation_delay)
	
	var percent = _timer / animation_duration
	_visualizer.zoom_to(percent)
