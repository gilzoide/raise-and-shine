# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Reference


func apply_height_increments(height_data: HeightMapData, values: PoolVector2Array, amount: float) -> void:
	var height_array = height_data.height_array
	var luminance_array = height_data.luminance_array
	for index_depth in values:
		var index = index_depth.x
		var depth = index_depth.y
		var height = clamp(height_array[index] + depth * amount, 0, 1)
		height_array[index] = height
		luminance_array[index] = int(height * 255)
	height_data.height_array = height_array
	height_data.luminance_array = luminance_array


func fill_normalmap(height_array: PoolRealArray, normalmap: Image, rect: Rect2) -> void:
	var size = normalmap.get_size()
	var bump_scale = min(size.x, size.y)
	var stride = size.x
	normalmap.lock()
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var here = height_array[y * stride + x]
			var right = height_array[y * stride + posmod(x + 1, size.x)]
			var below = height_array[posmod(y + 1, size.y) * stride + x]
			var up = Vector3(0, 1, (here - below) * bump_scale)
			var across = Vector3(1, 0, (right - here) * bump_scale)
			var normal = across.cross(up).normalized()
			var normal_rgb = normal * 0.5 + Vector3(0.5, 0.5, 0.5)
			normalmap.set_pixel(x, y, Color(normal_rgb.x, normal_rgb.y, normal_rgb.z, 1))
	normalmap.unlock()
