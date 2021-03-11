# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends OptionButton


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			select(posmod(selected - 1, get_item_count()))
			emit_signal("item_selected", selected)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			select(posmod(selected + 1, get_item_count()))
			emit_signal("item_selected", selected)
