# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends MeshInstance

export(float) var mesh_size = 1
export(int) var point_count = 64


func _ready() -> void:
	var points = PoolVector2Array()
	var radius = mesh_size * 0.5
	var angle_inc = TAU / float(point_count)
	var initial_vec = Vector2(radius, 0)
	for i in point_count:
		points.append(initial_vec.rotated(angle_inc * i))
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
