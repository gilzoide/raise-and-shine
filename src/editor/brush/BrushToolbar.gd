extends PanelContainer

enum {
	INCREASE_SIZE,
	INCREASE_SIZE_FASTER,
	DECREASE_SIZE,
	DECREASE_SIZE_FASTER,
}

export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")
export(int) var faster_size_amount = 10

onready var menu_button = $HBoxContainer/MenuButton
onready var format_picker = $HBoxContainer/FormatPicker
onready var easing_picker = $HBoxContainer/EasingPicker
onready var size_slider = $HBoxContainer/SizeSlider
onready var size_label = $HBoxContainer/SizeLabel

func _ready() -> void:
	var menu_popup = menu_button.get_popup()
	menu_popup.add_item("Increase size", INCREASE_SIZE)
	menu_popup.set_item_shortcut(INCREASE_SIZE, preload("res://shortcuts/BrushSizeIncrease_shortcut.tres"))
	menu_popup.add_item("Increase size by %d" % faster_size_amount, INCREASE_SIZE_FASTER)
	menu_popup.set_item_shortcut(INCREASE_SIZE_FASTER, preload("res://shortcuts/BrushSizeIncreaseFaster_shortcut.tres"))
	menu_popup.add_item("Decrease size", DECREASE_SIZE)
	menu_popup.set_item_shortcut(DECREASE_SIZE, preload("res://shortcuts/BrushSizeDecrease_shortcut.tres"))
	menu_popup.add_item("Decrease size by %d" % faster_size_amount, DECREASE_SIZE_FASTER)
	menu_popup.set_item_shortcut(DECREASE_SIZE_FASTER, preload("res://shortcuts/BrushSizeDecreaseFaster_shortcut.tres"))
	menu_popup.connect("id_pressed", self, "_on_menu_popup_id_pressed")
	
	format_picker.add_item("Circle", brush.Format.CIRCLE)
	format_picker.add_item("Square", brush.Format.SQUARE)
	format_picker.add_item("Rhombus", brush.Format.RHOMBUS)
	format_picker.selected = brush.Format.CIRCLE
	
	easing_picker.add_item("Flat", brush.Easing.FLAT)
	easing_picker.add_item("Linear", brush.Easing.LINEAR)
	easing_picker.add_item("Ease In", brush.Easing.EASE_IN)
	easing_picker.add_item("Ease Out", brush.Easing.EASE_OUT)
	easing_picker.add_item("Ease InOut", brush.Easing.EASE_INOUT)
	easing_picker.add_item("Circular In", brush.Easing.CIRCULAR_IN)
	easing_picker.add_item("Circular Out", brush.Easing.CIRCULAR_OUT)
	easing_picker.selected = 0

func _on_menu_popup_id_pressed(id: int) -> void:
	if id == INCREASE_SIZE:
		increase_brush_size()
	elif id == INCREASE_SIZE_FASTER:
		increase_brush_size(faster_size_amount)
	elif id == DECREASE_SIZE:
		decrease_brush_size(1)
	elif id == DECREASE_SIZE_FASTER:
		decrease_brush_size(faster_size_amount)

func _on_FormatPicker_item_selected(index: int) -> void:
	brush.format = index
	brush.set_parameter_changed()

func _on_EasingPicker_item_selected(index: int) -> void:
	brush.easing = index
	brush.set_parameter_changed()

func _on_SizeSlider_value_changed(value: float) -> void:
	brush.size = value
	brush.set_parameter_changed()
	size_label.text = str(int(value))

func increase_brush_size(factor: int = 1) -> void:
	assert(factor > 0, "FIXME!!!")
	size_slider.value += size_slider.step * factor

func decrease_brush_size(factor: int = 1) -> void:
	assert(factor > 0, "FIXME!!!")
	size_slider.value -= size_slider.step * factor
