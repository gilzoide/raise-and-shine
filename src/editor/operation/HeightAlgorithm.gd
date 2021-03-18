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
