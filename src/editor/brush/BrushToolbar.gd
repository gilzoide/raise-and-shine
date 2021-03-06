extends PanelContainer

export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")

onready var format_picker = $HBoxContainer/FormatPicker
onready var easing_picker = $HBoxContainer/EasingPicker
onready var size_label = $HBoxContainer/SizeLabel

func _ready() -> void:
	format_picker.add_item("Circle", brush.Format.CIRCLE)
	format_picker.add_item("Square", brush.Format.SQUARE)
	format_picker.selected = brush.Format.CIRCLE
	
	easing_picker.add_item("Flat", brush.Easing.FLAT)
	easing_picker.add_item("Linear", brush.Easing.LINEAR)
	easing_picker.add_item("Ease In", brush.Easing.EASE_IN)
	easing_picker.add_item("Ease Out", brush.Easing.EASE_OUT)
	easing_picker.add_item("Ease InOut", brush.Easing.EASE_INOUT)
	easing_picker.selected = 0

func _on_FormatPicker_item_selected(index: int) -> void:
	brush.format = index

func _on_EasingPicker_item_selected(index: int) -> void:
	brush.easing = index

func _on_SizeSlider_value_changed(value: float) -> void:
	brush.size = value
	size_label.text = str(int(value))
