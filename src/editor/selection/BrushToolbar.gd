extends PanelContainer

export(Resource) var brush = preload("res://editor/selection/ActiveBrush.tres")

onready var format_picker = $HBoxContainer/FormatPicker

func _ready() -> void:
	format_picker.add_item("Circle", brush.Format.CIRCLE)
	format_picker.add_item("Square", brush.Format.SQUARE)
	format_picker.selected = brush.Format.CIRCLE

func _on_FormatPicker_item_selected(index: int) -> void:
	brush.format = index

func _on_SizeSlider_value_changed(value: float) -> void:
	brush.size = value
