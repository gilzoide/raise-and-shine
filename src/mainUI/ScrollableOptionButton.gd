extends OptionButton

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			select(posmod(selected - 1, get_item_count()))
			emit_signal("item_selected", selected)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			select(posmod(selected + 1, get_item_count()))
			emit_signal("item_selected", selected)
