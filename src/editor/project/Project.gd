# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

signal albedo_texture_changed(texture)
signal height_texture_changed(texture, empty_data)
signal normal_texture_changed(texture)
signal height_changed(data, rect)

export(Image) var albedo_image: Image = MapTypes.ALBEDO_IMAGE
export(Image) var height_image: Image = MapTypes.HEIGHT_IMAGE
export(Image) var normal_image: Image = MapTypes.NORMAL_IMAGE
export(ImageTexture) var albedo_texture: ImageTexture = MapTypes.ALBEDO_TEXTURE
export(ImageTexture) var height_texture: ImageTexture = MapTypes.HEIGHT_TEXTURE
export(ImageTexture) var normal_texture: ImageTexture = MapTypes.NORMAL_TEXTURE
export(Resource) var history = preload("res://editor/undo/UndoHistory.tres")

var height_data: HeightMapData = HeightMapData.new()
var last_loaded_filename := ""


func _init() -> void:
	._init()
	height_image.create(64, 64, false, HeightMapData.HEIGHT_IMAGE_FORMAT)
	set_height_image(height_image)
	history.set_heightmapdata(height_data)
	history.connect("revision_changed", self, "set_height_data")


func set_height_data(data: HeightMapData, empty_data: bool = false) -> void:
	var previous_size = height_texture.get_size()
	height_data.copy_from(data)
	if empty_data:
		height_image.create(int(data.size.x), int(data.size.y), false, HeightMapData.HEIGHT_IMAGE_FORMAT)
		height_image.fill(HeightMapData.EMPTY_HEIGHT_COLOR)
		normal_image.create(int(data.size.x), int(data.size.y), false, HeightMapData.NORMAL_IMAGE_FORMAT)
		normal_image.fill(HeightMapData.EMPTY_NORMAL_COLOR)
	else:
		height_data.fill_image(height_image)
		normal_image = height_data.create_normalmap()
	height_texture.create_from_image(height_image, height_texture.flags)
	normal_texture.create_from_image(normal_image, normal_texture.flags)
	
	if previous_size != height_texture.get_size():
		emit_signal("height_texture_changed", height_texture, empty_data)
		emit_signal("normal_texture_changed", normal_texture)


func load_image_dialog(type: int) -> void:
	var method = ""
	if type == MapTypes.Type.ALBEDO_MAP:
		method = "set_albedo_image"
	elif type == MapTypes.Type.HEIGHT_MAP:
		method = "set_height_image"
	elif type == MapTypes.Type.NORMAL_MAP:
		method = "set_normal_image"
	assert(method != "", "Invalid map type %d" % type)
	ImageFileDialog.try_load_image(funcref(self, method))


func save_image_dialog(type: int) -> void:
	var image: Image = null
	var filename = last_loaded_filename if last_loaded_filename != "" else "raise_and_shine_generated"
	if type == MapTypes.Type.ALBEDO_MAP:
		image = albedo_image
	elif type == MapTypes.Type.HEIGHT_MAP:
		image = height_image
		filename += "_height"
	elif type == MapTypes.Type.NORMAL_MAP:
		image = normal_image
		filename += "_normal"
	assert(image != null, "Invalid map type %d" % type)
	filename += ".png"
	ImageFileDialog.try_save_image(image, filename)


func load_project_dialog() -> void:
	ImageFileDialog.try_load_image(funcref(self, "on_project_dialog_image"))


func on_project_dialog_image(value: Image, path: String = "") -> void:
	last_loaded_filename = path.get_file().get_basename()
	set_albedo_image(value)
	var new_height_data = HeightMapData.new()
	new_height_data.create(value.get_size())
	set_height_data(new_height_data, true)


func set_albedo_image(value: Image, _path: String = "") -> void:
	albedo_image = value
	albedo_texture.create_from_image(albedo_image, albedo_texture.flags)
	emit_signal("albedo_texture_changed", albedo_texture)


func set_height_image(value: Image, _path: String = "") -> void:
	height_image.copy_from(value)
	height_image.convert(HeightMapData.HEIGHT_IMAGE_FORMAT)
	height_data.copy_from_image(height_image)
	height_texture.create_from_image(height_image, height_texture.flags)
	emit_signal("height_texture_changed", height_texture, false)
	set_normal_image(height_data.create_normalmap())


func set_normal_image(value: Image, _path: String = "") -> void:
	normal_image.copy_from(value)
	normal_texture.create_from_image(normal_image, normal_texture.flags)
	emit_signal("normal_texture_changed", normal_texture)


func apply_operation(operation, amount: float) -> void:
	operation.apply(height_data, amount)
	height_data.fill_image(height_image)
	height_texture.set_data(height_image)
	var changed_rect = operation.cached_rect.grow(1).clip(Rect2(Vector2.ZERO, height_data.size))
	height_data.fill_normalmap(normal_image, changed_rect)
	normal_texture.set_data(normal_image)


func height_operation_ended(operation) -> void:
	history.push_heightmapdata(height_data)
	var changed_rect = operation.cached_rect.grow(1).clip(Rect2(Vector2.ZERO, height_data.size))
	emit_signal("height_changed", height_data, changed_rect)


func resize_maps(size: Vector2) -> void:
	if height_data.size != size:
		height_data.resize(size)
		history.push_heightmapdata(height_data)
		set_height_data(height_data)
