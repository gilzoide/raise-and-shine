# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
tool
extends Control

export(Resource) var resource = preload("res://editor/brush/ActiveBrush.tres")
export(String) var property := "size" setget set_property
export(float) var faster_factor = 10
export(bool) var wrap_around_value = false
export(ShortCut) var global_up_shortcut: ShortCut = null
export(ShortCut) var global_down_shortcut: ShortCut = null

var _initial_value
onready var _label = $Header/Label
onready var _spinbox = $Header/SpinBox
onready var _slider = $Slider


func _ready() -> void:
	_initial_value = resource.get(property)
	_label.text = property.capitalize()
	_spinbox.share(_slider)
	_spinbox.value = _initial_value
	_spinbox.connect("value_changed", self, "_on_value_changed")
	
	set_process_unhandled_input(global_up_shortcut or global_down_shortcut)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_RIGHT:
			_spinbox.value = _initial_value
		elif event.button_index == BUTTON_WHEEL_UP:
			scroll_range(1)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			scroll_range(-1)


func _unhandled_input(event: InputEvent) -> void:
	if global_up_shortcut and event.is_pressed() and global_up_shortcut.is_shortcut(event):
		scroll_range(1)
	if global_down_shortcut and event.is_pressed() and global_down_shortcut.is_shortcut(event):
		scroll_range(-1)


func set_property(value: String) -> void:
	property = value
	if _label:
		_label.text = property.capitalize()


func set_max_value(max_value) -> void:
	_spinbox.max_value = max_value
	_slider.max_value = max_value


func scroll_range(factor: float) -> void:
	if Input.is_action_pressed("visualizer_3d_faster"):
		factor *= faster_factor
	var new_value = _spinbox.value + factor * _spinbox.step
	if wrap_around_value:
		if new_value > _spinbox.max_value:
			new_value -= _spinbox.max_value - _spinbox.min_value
		elif new_value < _spinbox.min_value:
			new_value += _spinbox.max_value - _spinbox.min_value
	_spinbox.value = new_value


func _on_value_changed(value) -> void:
	if is_nan(value) or is_inf(value):
		_spinbox.value = _initial_value
		return
	resource.set(property, value)
