# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends CollisionObject

signal color_changed(color)
signal energy_changed(energy)

export(float) var max_energy = 10
onready var light = $SpotLight
onready var sphere = $SphereMesh
var dragging: bool = false


func _input_event(camera: Object, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
			dragging = event.is_pressed()
	elif dragging and event is InputEventMouseMotion:
		var position_in_xy = Plane.PLANE_XY.intersects_ray(
			camera.project_ray_origin(event.position),
			camera.project_ray_normal(event.position)
		)
		if position_in_xy:
			translation = position_in_xy


func set_light_color(color: Color) -> void:
	if color != light.light_color:
		light.light_color = color
		sphere.material_override.albedo_color = color
		emit_signal("color_changed", color)


func get_light_color() -> Color:
	return light.light_color


func set_light_energy(value: float) -> void:
	value = clamp(value, 0, max_energy)
	if not is_equal_approx(value, light.light_energy):
		light.light_energy = value
		emit_signal("energy_changed", value)


func get_light_energy() -> float:
	return light.light_energy
