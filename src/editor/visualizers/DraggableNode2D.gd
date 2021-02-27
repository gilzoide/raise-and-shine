extends Node2D

export(float) var radius: float = 25

onready var radius_squared = radius * radius
var dragging = false
onready var sprite = $Sprite

func is_mouse_over() -> bool:
	return sprite.get_rect().has_point(sprite.get_local_mouse_position())

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed() and is_mouse_over():
		dragging = true
	elif event is InputEventMouseButton and not event.is_pressed():
		dragging = false

func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position()
