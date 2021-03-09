extends Control

const SELECTED_COLOR = Color.white
const NOT_SELECTED_COLOR = Color.black

export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")
export(Rect2) var selection_rect: Rect2

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, rect_size), NOT_SELECTED_COLOR)
	if not selection_rect.has_no_area():
		if brush.format == brush.Format.SQUARE:
			draw_rect(selection_rect, SELECTED_COLOR)
		elif brush.format == brush.Format.CIRCLE:
			var half_size = selection_rect.size / 2
			var center = selection_rect.position + half_size
			var radius = min(half_size.x, half_size.y)
			draw_circle(center, radius, SELECTED_COLOR)
	
