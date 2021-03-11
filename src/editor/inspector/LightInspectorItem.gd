# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

onready var label = $Title
onready var check_button = $CheckButton
onready var energy_slider = $EnergySlider
onready var color_picker = $ColorPickerButton
var light: Node


func _ready() -> void:
	assert(light != null, "FIXME!!!")
	update_color_picker(light.get_light_color())
	update_energy_slider_value(light.get_light_energy())
	if light.has_signal("color_changed"):
		var _err = light.connect("color_changed", self, "update_color_picker")
	if light.has_signal("energy_changed"):
		var _err = light.connect("energy_changed", self, "update_energy_slider_value")


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP and event.is_pressed():
		energy_slider.value += energy_slider.step
	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN and event.is_pressed():
		energy_slider.value -= energy_slider.step


func set_name_index(index: int):
	if index >= 0:
		label.visible = false
		check_button.visible = true
		check_button.pressed = light.visible
		check_button.text = "%d" % index
	else:
		label.visible = true
		check_button.visible = false
		label.text = "Ambient"


func update_energy_slider_value(value: float) -> void:
	energy_slider.value = value


func update_color_picker(color: Color) -> void:
	color_picker.color = color


func _on_EnergySlider_value_changed(value: float) -> void:
	light.set_light_energy(value)


func _on_ColorPickerButton_color_changed(color: Color) -> void:
	light.set_light_color(color)


func _on_CheckButton_toggled(button_pressed: bool) -> void:
	light.visible = button_pressed
