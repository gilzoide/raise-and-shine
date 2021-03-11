# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Popup

onready var light_editor = $LightEditor

var color_changed: FuncRef
var energy_changed: FuncRef


func _notification(what: int) -> void:
	if what == NOTIFICATION_POPUP_HIDE:
		color_changed = null
		energy_changed = null


func popup_at(position: Vector2, current_color: Color, color_changed_func: FuncRef, energy_changed_func: FuncRef) -> void:
	light_editor.color = current_color
	color_changed = color_changed_func
	energy_changed = energy_changed_func
	var rect = Rect2(position, rect_size)
	popup(rect)


func _on_color_changed(color: Color) -> void:
	if color_changed:
		color_changed.call_func(color)


func _on_energy_changed(energy) -> void:
	if energy_changed:
		energy_changed.call_func(energy)
