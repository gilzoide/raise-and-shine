# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
tool
extends Control

export(Resource) var resource = preload("res://editor/brush/ActiveBrush.tres")
export(String) var property := "size" setget set_property

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


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_RIGHT:
			_spinbox.value = _initial_value
		elif event.button_index == BUTTON_WHEEL_UP:
			_spinbox.value += _spinbox.step
		elif event.button_index == BUTTON_WHEEL_DOWN:
			_spinbox.value -= _spinbox.step


func set_property(value: String) -> void:
	property = value
	if _label:
		_label.text = property.capitalize()


func _on_value_changed(value) -> void:
	resource.set(property, value)
