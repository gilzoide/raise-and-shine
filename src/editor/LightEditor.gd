extends Popup

onready var color_picker = $ColorPicker

var color_changed: FuncRef

func popup_at(position: Vector2, current_color: Color, color_changed_func: FuncRef) -> void:
	color_picker.color = current_color
	color_changed = color_changed_func
	var rect = Rect2(position, rect_size)
	popup(rect)

func _notification(what: int) -> void:
	if what == NOTIFICATION_POPUP_HIDE:
		color_changed = null

func _on_ColorPicker_color_changed(color: Color) -> void:
	if color_changed:
		color_changed.call_func(color)
