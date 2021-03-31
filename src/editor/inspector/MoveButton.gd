extends Button

signal moved(relative)
signal reset()

var _moving = false


func _ready() -> void:
	var _err = connect("button_down", self, "_on_button_down")
	_err = connect("button_up", self, "_on_button_up")


func _gui_input(event: InputEvent) -> void:
	if _moving and event is InputEventMouseMotion:
		emit_signal("moved", event.relative)
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and not event.is_pressed():
		emit_signal("reset")


func _on_button_down() -> void:
	var toast = Toast.new("Hold down and move light with mouse", Toast.LENGTH_LONG)
	get_tree().root.add_child(toast)
	toast.show()
	
	_moving = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_button_up() -> void:
	_moving = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	warp_mouse(rect_size * 0.5)
