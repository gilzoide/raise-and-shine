extends VSlider

func show_at_position(global_position: Vector2) -> void:
	rect_global_position = global_position - rect_pivot_offset
	visible = true
