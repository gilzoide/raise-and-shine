extends Button

signal moved(relative)

var _moving = false


func _ready() -> void:
	var _err = connect("button_down", self, "_on_button_down")
	_err = connect("button_up", self, "_on_button_up")


func _gui_input(event: InputEvent) -> void:
	if _moving and event is InputEventMouseMotion:
		emit_signal("moved", event.relative)


func _on_button_down() -> void:
	_moving = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_button_up() -> void:
	_moving = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
