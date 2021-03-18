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


func create_normalmap(algorithm) -> Image:
	var normalmap = Image.new()
	normalmap.create(size.x, size.y, false, NORMAL_IMAGE_FORMAT)
	algorithm.fill_normalmap(height_array, normalmap, Rect2(Vector2.ZERO, size))
	return normalmap


func resize(new_size: Vector2) -> void:
	var image = create_image()
	image.resize(int(new_size.x), int(new_size.y))
	copy_from_image(image)
