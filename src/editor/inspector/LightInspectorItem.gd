extends Control

onready var title = $Label
onready var energy_slider = $EnergySlider
onready var color_picker = $ColorPickerButton
var light: Node

func _ready() -> void:
	assert(light != null, "FIXME!!!")
	update_color_picker()
	update_energy_slider_value()
	light.connect("color_changed", self, "update_color_picker")
	light.connect("energy_changed", self, "update_energy_slider_value")

func set_name_index(index: int):
	title.text = "Ambient" if index < 0 else "Light %d" % index

func update_energy_slider_value() -> void:
	energy_slider.value = light.get_light_energy()

func update_color_picker() -> void:
	color_picker.color = light.get_light_color()

func _on_EnergySlider_value_changed(value: float) -> void:
	light.set_light_energy(value)

func _on_ColorPickerButton_color_changed(color: Color) -> void:
	light.set_light_color(color)
