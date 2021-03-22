# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
class_name HeightAlgorithm

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
	var diff_scale_factor = 1.0 / 6.0 * bump_scale
	var stride = size.x
	normalmap.lock()
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var x_left = posmod(x - 1, size.x)
			var x_right = posmod(x + 1, size.x)
			var y_top = posmod(y - 1, size.y)
			var y_bottom = posmod(y + 1, size.y)
			
			# Ref: https://github.com/Scrawk/Terrain-Topology-Algorithms/blob/afe65384254462073f41984c4c8e7e029275d830/Assets/TerrainTopology/Scripts/CreateTopolgy.cs#L162
			var z1 = height_array[y_bottom * stride + x_left]
			var z2 = height_array[y_bottom * stride + x]
			var z3 = height_array[y_bottom * stride + x_right]
			var z4 = height_array[y * stride + x_left]
			var z6 = height_array[y * stride + x_right]
			var z7 = height_array[y_top * stride + x_left]
			var z8 = height_array[y_top * stride + x]
			var z9 = height_array[y_top * stride + x_right]

			var zx = (z3 + z6 + z9 - z1 - z4 - z7) * diff_scale_factor
			var zy = (z1 + z2 + z3 - z7 - z8 - z9) * diff_scale_factor
			var normal = Vector3(-zx, zy, 1.0).normalized()

			var normal_rgb = normal * 0.5 + Vector3(0.5, 0.5, 0.5)
			normalmap.set_pixel(x, y, Color(normal_rgb.x, normal_rgb.y, normal_rgb.z, 1))
	normalmap.unlock()


static func fill_height_image(image: Image, height_array: PoolRealArray) -> void:
	var size = image.get_size()
	assert(height_array.size() == size.x * size.y, "Image is incompatible with height array!")
	var stream_peer = StreamPeerBuffer.new()
	for height in height_array:
		stream_peer.put_float(height)
	image.create_from_data(size.x, size.y, false, Image.FORMAT_RF, stream_peer.data_array)
