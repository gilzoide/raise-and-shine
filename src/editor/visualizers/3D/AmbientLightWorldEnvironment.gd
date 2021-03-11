# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends WorldEnvironment


func set_light_color(color: Color) -> void:
	environment.ambient_light_color = color


func get_light_color() -> Color:
	return environment.ambient_light_color


func set_light_energy(value: float) -> void:
	environment.ambient_light_energy = value


func get_light_energy() -> float:
	return environment.ambient_light_energy
