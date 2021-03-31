# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends ToolButton

signal preset_chosen(curve)

onready var _popup = $PresetsPopup
onready var _buttons = $PresetsPopup/VBoxContainer.get_children()


func _ready() -> void:
	for b in _buttons:
		var curve = b.get_node("CubicBezierRect").curve
		b.connect("pressed", self, "_on_button_pressed", [curve])


func _on_pressed() -> void:
	var global_rect = get_global_rect()
	var point = Vector2(global_rect.position.x, global_rect.position.y + global_rect.size.y)
	_popup.popup(Rect2(point, _popup.rect_size))


func _on_button_pressed(curve) -> void:
	emit_signal("preset_chosen", curve)
