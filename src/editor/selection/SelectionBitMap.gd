# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
class_name SelectionBitMap

extends BitMap

const TRUE_COLOR = Color.white
const FALSE_COLOR = Color.black

enum Format {
	RECTANGLE,
	ELLIPSE,
	LINE,
	PENCIL,
}


func copy_from(bitmap: BitMap) -> void:
	data = bitmap.data


func clear(bit: bool = false) -> void:
	set_bit_rect(Rect2(Vector2.ZERO, get_size()), bit)


func create_image() -> Image:
	var image = Image.new()
	var size = get_size()
	image.create(size.x, size.y, false, Image.FORMAT_L8)
	blit_to_image(image)
	return image


func blit(bitmap: BitMap, dst := Vector2.ZERO) -> void:
	var self_size = get_size()
	var bitmap_size = bitmap.get_size()
	dst.x = max(dst.x, 0)
	dst.y = max(dst.y, 0)
	for x in min(self_size.x - dst.x, bitmap_size.x):
		for y in min(self_size.y - dst.y, bitmap_size.y):
			var dst_v = Vector2(x, y) + dst
			set_bit(dst_v, bitmap.get_bit(dst_v))


func blit_to_image(image: Image, dst := Vector2.ZERO) -> void:
	var self_size = get_size()
	var image_size = image.get_size()
	dst.x = max(dst.x, 0)
	dst.y = max(dst.y, 0)
	image.lock()
	for x in min(self_size.x - dst.x, image_size.x):
		for y in min(self_size.y - dst.y, image_size.y):
			image.set_pixel(x, y, TRUE_COLOR if get_bit(Vector2(x, y)) else FALSE_COLOR)
	image.unlock()


func blend_sum(bitmap: BitMap, dst: Vector2) -> void:
	var bitmap_size = bitmap.get_size()
	var bounds = Rect2(Vector2.ZERO, get_size())
	for x in bitmap_size.x:
		for y in bitmap_size.y:
			var v = Vector2(x, y)
			var dst_v = dst + v
			if bounds.has_point(dst_v):
				set_bit(dst_v, get_bit(dst_v) or bitmap.get_bit(v))


func blend_difference(bitmap: BitMap, dst: Vector2) -> void:
	var bitmap_size = bitmap.get_size()
	var bounds = Rect2(Vector2.ZERO, get_size())
	for x in bitmap_size.x:
		for y in bitmap_size.y:
			var v = Vector2(x, y)
			var dst_v = dst + v
			if bounds.has_point(dst_v):
				set_bit(dst_v, get_bit(dst_v) and not bitmap.get_bit(v))


func create_format(size: Vector2, line_direction: float, format: int) -> void:
	create(size)
	if format == Format.RECTANGLE:
		set_bit_rect(Rect2(Vector2.ZERO, size), true)
	elif format == Format.ELLIPSE:
		var half_size = size / 2
		var squared_size_x = half_size.x * half_size.x
		var squared_size_y = half_size.y * half_size.y
		for x in size.x:
			for y in size.y:
				var centered_x = x - half_size.x
				var centered_y = y - half_size.y
				set_bit(Vector2(x, y), (centered_x * centered_x) / squared_size_x + (centered_y * centered_y) / squared_size_y <= 1.0)
	elif format == Format.LINE:
		if is_equal_approx(size.x, 1.0) or is_equal_approx(size.y, 1.0):
			set_bit_rect(Rect2(Vector2.ZERO, size), true)
		else:
			# Bresenham's line algorithm
			var x0 := 0
			var y0 := 0 if line_direction > 0 else int(size.y - 1)
			var x1 := int(size.x - 1)
			var y1 := int(size.y - 1) if line_direction > 0 else 0
			var sy := int(line_direction)
			var dx = int(size.x - 1)
			var dy = -(size.y - 1)
			var err = dx + dy
			while x0 != x1 or y0 != y1:
				set_bit(Vector2(x0, y0), true)
				var e2 = 2 * err
				if e2 >= dy:
					err += dy
					x0 += 1
				if e2 <= dx:
					err += dx
					y0 += sy
			set_bit(Vector2(x0, y0), true)
	elif format == Format.PENCIL:
		# Pencil will be manually painted
		pass
	else:
		assert(false, "FIXME!!!")


func invert() -> void:
	var size = get_size()
	for x in size.x:
		for y in size.y:
			var v = Vector2(x, y)
			set_bit(v, not get_bit(v))


func get_true_rect() -> Rect2:
	var size = get_size()
	var min_x = size.x
	var min_y = size.y
	var max_x = -1
	var max_y = -1
	for x in size.x:
		for y in size.y:
			if get_bit(Vector2(x, y)):
				min_x = min(x, min_x)
				min_y = min(y, min_y)
				max_x = max(x, max_x)
				max_y = max(y, max_y)
	return Rect2(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
