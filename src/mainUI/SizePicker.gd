# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

signal width_changed(width)
signal height_changed(height)

export(int) var width := 64
export(int) var height := 64

var keep_aspect := true
var aspect := 1.0

onready var width_picker = $WidthSpinBox
onready var height_picker = $HeightSpinBox
onready var aspect_button = $AspectCheckButton


func _ready() -> void:
	update_values()


func set_values(size: Vector2) -> void:
	width = int(clamp(size.x, width_picker.min_value, width_picker.max_value))
	height = int(clamp(size.y, height_picker.min_value, height_picker.max_value))
	aspect = size.aspect()
	update_values()


func picked_size() -> Vector2:
	return Vector2(width, height)


func update_values() -> void:
	width_picker.value = width
	height_picker.value = height
	aspect_button.pressed = keep_aspect


func focus_first() -> void:
	var line_edit = width_picker.get_line_edit()
	line_edit.grab_focus()
	line_edit.select_all()


func _on_WidthSpinBox_value_changed(value: float) -> void:
	if not is_equal_approx(value, width):
		width = int(value)
		if keep_aspect:
			height = int(width / aspect)
			height_picker.value = height
		emit_signal("width_changed", width)


func _on_HeightSpinBox_value_changed(value: float) -> void:
	if not is_equal_approx(value, height):
		height = int(value)
		if keep_aspect:
			width = int(aspect * height)
			width_picker.value = width
		emit_signal("height_changed", height)


func _on_AspectCheckButton_toggled(button_pressed: bool) -> void:
	keep_aspect = button_pressed
	if keep_aspect:
		aspect = float(width) / float(height)
