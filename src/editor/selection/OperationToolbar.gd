extends HBoxContainer

onready var operation_picker = $OperationPicker
onready var amount_slider = $AmountSlider
const operation = preload("res://editor/selection/ActiveOperation.tres")

func _ready() -> void:
	operation_picker.add_item("Increase by", operation.Operation.INCREASE_BY)
	operation_picker.add_item("Decrease by", operation.Operation.DECREASE_BY)
	operation_picker.add_item("Set value", operation.Operation.SET_VALUE)
	operation_picker.selected = 0

func _on_OperationPicker_item_selected(index: int) -> void:
	operation.type = index

func _on_AmountSlider_value_changed(value: float) -> void:
	operation.amount = value

