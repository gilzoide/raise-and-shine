extends VBoxContainer

export(float) var animation_duration = 5
export(float) var animation_delay = 1

var _speed = 1
var _timer = 0

onready var _animation_container = $PerspectiveVisualizer
onready var _model = $PerspectiveVisualizer/ViewportContainer/Viewport/Model
onready var _material: ShaderMaterial = _model.material_override
onready var _cursor_icon = $PerspectiveVisualizer/CursorIcon


func _ready() -> void:
	set_process(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			_timer = 0
			_speed = 1
		set_process(visible)


func _process(delta: float) -> void:
	_timer += _speed * delta
	if _timer >= animation_duration + animation_delay or _timer <= -animation_delay:
		_speed = -_speed
		_timer = clamp(_timer, -animation_delay, animation_duration + animation_delay)
	
	var percent = clamp(_timer / animation_duration, 0, 1)
	_cursor_icon.position = _animation_container.rect_size * lerp(Vector2(0.7, 0.7), Vector2(0.7, 0.3), percent)
	_material.set_shader_param("height", percent)
