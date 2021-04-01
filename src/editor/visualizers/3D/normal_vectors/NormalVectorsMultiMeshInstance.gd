# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends MultiMeshInstance

const PIXEL_CENTER_OFFSET = Vector2(0.5, 0.5)

export(float) var vector_height: float = 5


func _ready() -> void:
	var vertices = PoolVector3Array()
	vertices.append(Vector3(-0.5, 0, -0.5))
	vertices.append(Vector3(0.5, 0, 0.5))
	vertices.append(Vector3(-0.5, 0, 0.5))
	vertices.append(Vector3(0.5, 0, -0.5))
	vertices.append(Vector3(0, 0, 0))
	vertices.append(Vector3(0, vector_height, 0))
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	multimesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	multimesh.instance_count = 4096
	material_override.set_shader_param("normal_map", NormalDrawer.get_texture())


func set_plane_size(plane_size: Vector2) -> void:
	material_override.set_shader_param("plane_size", plane_size)
	multimesh.instance_count = int(plane_size.x * plane_size.y)


func set_height_scale(height_scale: float) -> void:
	material_override.set_shader_param("height_scale", height_scale)


func set_map_size(map_size: Vector2) -> void:
	material_override.set_shader_param("map_size", map_size)
	multimesh.instance_count = int(map_size.x * map_size.y)
