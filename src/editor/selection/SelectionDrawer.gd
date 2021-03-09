extends Viewport

export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")
onready var canvas_item = $BrushCanvasItem

func _ready() -> void:
	brush.connect("parameter_changed", self, "redraw")
	brush.connect("selection_rect_changed", self, "redraw_rect")

func redraw_rect(rect: Rect2 = Rect2(Vector2.ZERO, size)) -> void:
	canvas_item.selection_rect = rect
	redraw()

func redraw() -> void:
	render_target_update_mode = Viewport.UPDATE_ONCE
	canvas_item.update()
