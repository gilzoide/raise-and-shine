extends Control

onready var label = $Label

func show_at_position(global_position: Vector2) -> void:
	rect_global_position = global_position - rect_pivot_offset
	visible = true

func update_height(height: float) -> void:
	label.text = "%.2f" % height

