# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
class_name HeightMapData

extends Reference

const HEIGHT_IMAGE_FORMAT = Image.FORMAT_L8
const NORMAL_IMAGE_FORMAT = Image.FORMAT_RGB8
const EMPTY_HEIGHT_COLOR = Color(0, 0, 0)
const EMPTY_NORMAL_COLOR = Color(0.5, 0.5, 1)

var luminance_array := PoolByteArray()
var height_array := PoolRealArray()
var size: Vector2 = Vector2.ZERO


func create(new_size: Vector2) -> void:
	size = new_size
	var pixel_count = int(size.x * size.y)
	luminance_array.resize(pixel_count)
	height_array.resize(pixel_count)
	for i in pixel_count:
		luminance_array[i] = 0
		height_array[i] = 0


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


func get_value(x: int, y: int) -> float:
	return height_array[y * size.x + x]


func set_value(x: int, y: int, value: float) -> void:
	var index = y * size.x + x
	height_array[index] = value
	luminance_array[index] = int(value * 255)


func increment_all_values(values: PoolVector2Array, amount: float) -> void:
	for index_depth in values:
		var index = index_depth.x
		var depth = index_depth.y
		var height = clamp(height_array[index] + depth * amount, 0, 1)
		height_array[index] = height
		luminance_array[index] = int(height * 255)


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
	normalmap.create(size.x, size.y, false, NORMAL_IMAGE_FORMAT)
	fill_normalmap(normalmap)
	return normalmap


func fill_normalmap(normalmap: Image, rect: Rect2 = Rect2(Vector2.ZERO, size)) -> void:
	var bounds = size
	var bump_scale = min(bounds.x, bounds.y)
	var stride = size.x
	normalmap.lock()
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var here = height_array[y * stride + x]
			var right = height_array[y * stride + posmod(x + 1, bounds.x)]
			var below = height_array[posmod(y + 1, bounds.y) * stride + x]
			var up = Vector3(0, 1, (here - below) * bump_scale)
			var across = Vector3(1, 0, (right - here) * bump_scale)
			var normal = across.cross(up).normalized()
			var normal_rgb = normal * 0.5 + Vector3(0.5, 0.5, 0.5)
			normalmap.set_pixel(x, y, Color(normal_rgb.x, normal_rgb.y, normal_rgb.z, 1))
	normalmap.unlock()


func resize(new_size: Vector2) -> void:
	var image = create_image()
	image.resize(int(new_size.x), int(new_size.y))
	copy_from_image(image)
