# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends ArrayMesh

export(float) var mesh_size = 1 setget set_mesh_size
export(int) var point_count = 64 setget set_point_count

func _init() -> void:
	_rebuild()


func set_mesh_size(value: float) -> void:
	if value != mesh_size:
		mesh_size = value
		_rebuild()


func set_point_count(value: int) -> void:
	if value != point_count:
		point_count = value
		_rebuild()


func _rebuild() -> void:
	while get_surface_count() > 0:
		surface_remove(0)
	var points = PoolVector2Array()
	var radius = mesh_size * 0.5
	var angle_inc = TAU / float(point_count)
	var initial_vec = Vector2(radius, 0)
	for i in point_count:
		points.append(initial_vec.rotated(angle_inc * i))
	var arrays = []
	arrays.resize(ARRAY_MAX)
	arrays[ARRAY_VERTEX] = points
	add_surface_from_arrays(PRIMITIVE_LINES, arrays)
