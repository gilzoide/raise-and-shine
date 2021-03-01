extends Control

signal color_changed(color)
signal energy_changed(energy)

var color: Color setget set_color
var energy: float setget set_energy
onready var color_picker = $ColorPicker
onready var energy_slider = $EnergyEditor/HSlider

func set_color(value: Color) -> void:
	color_picker.color = value

func set_energy(value: float) -> void:
	energy_slider.value = value

func _on_ColorPicker_color_changed(color_: Color) -> void:
	emit_signal("color_changed", color_)


func _on_energy_value_changed(value: float) -> void:
	emit_signal("energy_changed", value)
