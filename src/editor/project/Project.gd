# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

signal albedo_texture_changed(texture)
signal height_texture_changed(texture, empty_data)
signal normal_texture_changed(texture)

export(Image) var albedo_image: Image = preload("res://textures/P1_2_Hair.png")
export(Image) var height_image: Image = Image.new()
export(Image) var normal_image: Image = Image.new()
export(ImageTexture) var albedo_texture: ImageTexture = MapTypes.ALBEDO_TEXTURE
export(ImageTexture) var albedo_srgb_texture: ImageTexture = MapTypes.ALBEDO_SRGB_TEXTURE
export(ImageTexture) var height_texture: ImageTexture = MapTypes.HEIGHT_TEXTURE
export(ImageTexture) var normal_texture: ImageTexture = MapTypes.NORMAL_TEXTURE
export(Resource) var history = preload("res://editor/undo/UndoHistory.tres")

var last_loaded_filename := ""


func _init() -> void:
	var albedo_size = albedo_image.get_size()
	height_image.create(albedo_size.x, albedo_size.y, false, MapTypes.HEIGHT_IMAGE_FORMAT)
	set_height_image(height_image)
	history.init_heightmap(height_image)
	history.connect("revision_changed", self, "_on_history_revision_changed")


func set_height_image(image: Image, empty_data: bool = false) -> void:
	height_image = image
	height_texture.create_from_image(height_image, height_texture.flags)
	emit_signal("height_texture_changed", height_texture, empty_data)


func load_image_dialog(type: int) -> void:
	var method = ""
	if type == MapTypes.Type.ALBEDO_MAP:
		method = "set_albedo_image"
	elif type == MapTypes.Type.HEIGHT_MAP:
		method = "_on_height_image_loaded"
	elif type == MapTypes.Type.NORMAL_MAP:
		method = "set_normal_image"
	assert(method != "", "Invalid map type %d" % type)
	ImageFileDialog.try_load_image(funcref(self, method))


func save_image_dialog_type(type: int) -> void:
	var image: Image = null
	var suffix = ""
	if type == MapTypes.Type.ALBEDO_MAP:
		image = albedo_image
	elif type == MapTypes.Type.HEIGHT_MAP:
		image = HeightDrawer.get_texture().get_data()
		suffix = "_height"
	elif type == MapTypes.Type.NORMAL_MAP:
		image = NormalDrawer.get_texture().get_data()
		suffix = "_normal"
	assert(image != null, "Invalid map type %d" % type)
	save_image_dialog(image, suffix)


func save_image_dialog(image: Image, suffix: String = "") -> void:
	var filename = last_loaded_filename if last_loaded_filename != "" else "raise_and_shine_generated"
	filename += suffix
	filename += ".png"
	ImageFileDialog.try_save_image(image, filename)


func load_project_dialog() -> void:
	ImageFileDialog.try_load_image(funcref(self, "on_project_dialog_image"))


func on_project_dialog_image(value: Image, path: String = "") -> void:
	last_loaded_filename = path.get_file().get_basename()
	set_albedo_image(value)
	var new_size = value.get_size()
	height_image.create(new_size.x, new_size.y, false, MapTypes.HEIGHT_IMAGE_FORMAT)
	set_height_image(height_image, true)
	history.push_revision(height_image)


func set_albedo_image(value: Image, _path: String = "") -> void:
	albedo_image = value
	albedo_texture.create_from_image(albedo_image, albedo_texture.flags)
	if OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES3:
		albedo_image.convert(Image.FORMAT_RGBAH)
		albedo_srgb_texture.create_from_image(albedo_image, albedo_srgb_texture.flags)
	emit_signal("albedo_texture_changed", albedo_texture)


func set_normal_image(value: Image, _path: String = "") -> void:
	normal_image = value
	normal_texture.create_from_image(normal_image, normal_texture.flags)
	emit_signal("normal_texture_changed", normal_texture)


func resize_maps(size: Vector2) -> void:
	if height_image.get_size() != size:
		height_image.resize(int(size.x), int(size.y))
		set_height_image(height_image)
		history.push_revision(height_image)


func _on_height_image_loaded(value: Image, _path: String = "") -> void:
	value.convert(MapTypes.HEIGHT_IMAGE_FORMAT)
	set_height_image(value)


func _on_history_revision_changed(revision) -> void:
	set_height_image(revision.heightmap)
