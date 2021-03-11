# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
class_name HeightMapData

extends Reference

const HEIGHT_IMAGE_FORMAT = Image.FORMAT_L8

var luminance_array: PoolByteArray
var height_array: PoolRealArray
var size: Vector2 = Vector2.ZERO


func copy_from(map: HeightMapData) -> void:
	luminance_array = map.luminance_array
	height_array = map.height_array
	size = map.size


func copy_from_image(image: Image) -> void:
	assert(image.get_format() == HEIGHT_IMAGE_FORMAT, "FIXME!!!")
	luminance_array = image.get_data()
	size = image.get_size()
	var pixel_count = int(size.x * size.y)
	height_array.resize(pixel_count)
	for i in pixel_count:
		height_array[i] = (luminance_array[i] / 255.0)


func get_index(x: int, y: int) -> int:
	return int(y * size.x + x)


func get_value(x: int, y: int) -> float:
	var index = get_index(x, y)
	return height_array[index]


func set_value(x: int, y: int, value: float) -> void:
	var index = get_index(x, y)
	height_array[index] = value
	luminance_array[index] = int(value * 255)


func scaled(scale: float) -> PoolRealArray:
	var result = PoolRealArray()
	var float_count = int(size.x * size.y)
	result.resize(float_count)
	for i in float_count:
		result[i] = height_array[i] * scale
	return result


func create_image() -> Image:
	var image = Image.new()
	fill_image(image)
	return image


func fill_image(image: Image) -> void:
	image.create_from_data(int(size.x), int(size.y), false, HEIGHT_IMAGE_FORMAT, luminance_array)


func create_normalmap() -> Image:
	var normalmap = Image.new()
	normalmap.create(size.x, size.y, false, Image.FORMAT_RGB8)
	fill_normalmap(normalmap)
	return normalmap


func fill_normalmap(normalmap: Image, rect: Rect2 = Rect2(Vector2.ZERO, size)) -> void:
	var bounds = size
	var bump_scale = min(bounds.x, bounds.y)
	normalmap.lock()
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var here = get_value(x, y)
			var right = get_value(x + 1, y) if x + 1 < bounds.x else here
			var below = get_value(x, y + 1) if y + 1 < bounds.y else here
			var up = Vector3(0, 1, (here - below) * bump_scale)
			var across = Vector3(1, 0, (right - here) * bump_scale)
			var normal = across.cross(up).normalized()
			var normal_rgb = normal * 0.5 + Vector3(0.5, 0.5, 0.5)
			normalmap.set_pixel(x, y, Color(normal_rgb.x, normal_rgb.y, normal_rgb.z, 1))
	normalmap.unlock()
