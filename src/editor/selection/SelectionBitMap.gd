# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
class_name SelectionBitMap

extends BitMap

var true_rect: Rect2


func create_from_image(image: Image) -> void:
	var size = image.get_size()
	create(size)
	var min_x = size.x
	var min_y = size.y
	var max_x = -1
	var max_y = -1
	image.lock()
	for x in size.x:
		for y in size.y:
			var bit = image.get_pixel(x, y).r > 0.5
			set_bit(Vector2(x, y), bit)
			if bit:
				min_x = min(x, min_x)
				min_y = min(y, min_y)
				max_x = max(x, max_x)
				max_y = max(y, max_y)
	image.unlock()
	true_rect = Rect2(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
