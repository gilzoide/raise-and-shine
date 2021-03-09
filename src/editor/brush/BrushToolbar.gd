extends PanelContainer

export(Resource) var selection = preload("res://editor/selection/ActiveSelection.tres")
export(Resource) var operation = preload("res://editor/operation/DragOperation.tres")
export(int) var faster_size_amount = 10

onready var easing_picker = $HBoxContainer/EasingPicker

func _ready() -> void:
	easing_picker.add_item("Flat", operation.Easing.FLAT)
	easing_picker.add_item("Linear", operation.Easing.LINEAR)
	easing_picker.add_item("Ease In", operation.Easing.EASE_IN)
	easing_picker.add_item("Ease Out", operation.Easing.EASE_OUT)
	easing_picker.add_item("Ease InOut", operation.Easing.EASE_INOUT)
	easing_picker.add_item("Circular In", operation.Easing.CIRCULAR_IN)
	easing_picker.add_item("Circular Out", operation.Easing.CIRCULAR_OUT)
	easing_picker.selected = 0

func _on_EasingPicker_item_selected(index: int) -> void:
	operation.easing = index

func _on_tool_button_pressed(op: int) -> void:
	selection.drag_operation = op
