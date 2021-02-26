extends Node2D

export(float) var radius: float = 25
onready var radius_squared = radius * radius
var dragging = false

func is_mouse_near() -> bool:
	var mouse_pos = get_local_mouse_position()
	return mouse_pos.length_squared() <= radius_squared

func _input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_pressed() and is_mouse_near():
		dragging = true
	elif event is InputEventMouseButton and not event.is_pressed():
		dragging = false

func _process(delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position()
