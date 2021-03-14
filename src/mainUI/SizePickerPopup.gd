# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Popup

signal size_confirmed(size)

onready var size_picker = $SizePicker


func popup_with_size(size: Vector2) -> void:
	size_picker.set_values(size)
	popup_centered()


func _on_confirmed() -> void:
	emit_signal("size_confirmed", size_picker.picked_size())
