# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

signal albedo_texture_changed(texture)
signal height_texture_changed(texture)
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


func _init() -> void:
	._init()
	height_image.create(64, 64, false, HeightMapData.HEIGHT_IMAGE_FORMAT)
	set_height_image(height_image)
	history.set_heightmapdata(height_data)
	history.connect("revision_changed", self, "set_height_data")


func set_height_data(data: HeightMapData) -> void:
	var previous_size = height_texture.get_size()
	height_data.copy_from(data)
	height_data.fill_image(height_image)
	height_texture.create_from_image(height_image, height_texture.flags)
	normal_image = height_data.create_normalmap()
	normal_texture.create_from_image(normal_image, normal_texture.flags)
	
	if previous_size != height_texture.get_size():
		emit_signal("height_texture_changed", height_texture)
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
	if type == MapTypes.Type.ALBEDO_MAP:
		image = albedo_image
	elif type == MapTypes.Type.HEIGHT_MAP:
		image = height_image
	elif type == MapTypes.Type.NORMAL_MAP:
		image = normal_image
	assert(image != null, "Invalid map type %d" % type)
	ImageFileDialog.try_save_image(image)


func load_project_dialog() -> void:
	ImageFileDialog.try_load_image(funcref(self, "on_project_dialog_image"))


func on_project_dialog_image(value: Image, _path: String = "") -> void:
	set_albedo_image(value)
	var new_height_data = HeightMapData.new()
	new_height_data.create(value.get_size())
	set_height_data(new_height_data)


func set_albedo_image(value: Image, _path: String = "") -> void:
	albedo_image = value
	albedo_texture.create_from_image(albedo_image, albedo_texture.flags)
	emit_signal("albedo_texture_changed", albedo_texture)


func set_height_image(value: Image, _path: String = "") -> void:
	height_image.copy_from(value)
	height_image.convert(HeightMapData.HEIGHT_IMAGE_FORMAT)
	height_data.copy_from_image(height_image)
	height_texture.create_from_image(height_image, height_texture.flags)
	emit_signal("height_texture_changed", height_texture)
	set_normal_image(height_data.create_normalmap())


func set_normal_image(value: Image, _path: String = "") -> void:
	normal_image.copy_from(value)
	normal_texture.create_from_image(normal_image, normal_texture.flags)
	emit_signal("normal_texture_changed", normal_texture)


func apply_operation_to(operation, bitmap: BitMap, rect: Rect2) -> void:
	operation.apply(height_data, bitmap, rect)
	height_data.fill_image(height_image)
	height_texture.set_data(height_image)
	var changed_rect = rect.grow(1).clip(Rect2(Vector2.ZERO, height_data.size))
	height_data.fill_normalmap(normal_image, changed_rect)
	normal_texture.set_data(normal_image)
	emit_signal("height_changed", height_data, changed_rect)


func operation_ended() -> void:
	history.push_heightmapdata(height_data)


func resize_maps(size: Vector2) -> void:
	if height_data.size != size:
		height_data.resize(size)
		history.push_heightmapdata(height_data)
		set_height_data(height_data)
