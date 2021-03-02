extends WorldEnvironment

func set_light_color(color: Color) -> void:
	environment.ambient_light_color = color

func get_light_color() -> Color:
	return environment.ambient_light_color

func set_light_energy(value: float) -> void:
	environment.ambient_light_energy = value

func get_light_energy() -> float:
	return environment.ambient_light_energy
