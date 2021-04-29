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

var _last_loaded_filename := ""
var _last_loaded_directory := ""


func _init() -> void:
	var albedo_size = albedo_image.get_size()
	height_image.create(albedo_size.x, albedo_size.y, false, MapTypes.HEIGHT_IMAGE_FORMAT)
	set_height_image(height_image)
	history.init_heightmap(height_image)
	history.connect("revision_changed", self, "_on_history_revision_changed")


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
	elif type == MapTypes.Type.ILLUMINATED_MAP:
		image = PhotoBooth.screenshot_viewport.get_texture().get_data()
		suffix = "_illuminated"
	assert(image != null, "Invalid map type %d" % type)
	save_image_dialog(image, suffix)


func save_image_dialog(image: Image, suffix: String = "") -> void:
	var filename = _last_loaded_filename if _last_loaded_filename != "" else "raise_and_shine_generated"
	filename += suffix
	filename += ".png"
	ImageFileDialog.try_save_image(image, filename)


func load_project_dialog() -> void:
	ImageFileDialog.try_load_image(funcref(self, "on_project_dialog_image"))


func on_project_dialog_image(value: Image, path: String = "") -> void:
	_last_loaded_filename = path.get_file().get_basename()
	_last_loaded_directory = path.get_base_dir()
	set_albedo_image(value)
	var img = _try_find_height_image_in_dir(_last_loaded_directory, _last_loaded_filename)
	var is_empty_data = img.is_empty()
	if is_empty_data:
		var new_size = value.get_size()
		height_image.create(new_size.x, new_size.y, false, MapTypes.HEIGHT_IMAGE_FORMAT)
	else:
		height_image = img
	set_height_image(height_image, is_empty_data)
	history.push_revision(height_image)


func set_albedo_image(value: Image, _path: String = "") -> void:
	albedo_image = value
	albedo_texture.create_from_image(albedo_image, albedo_texture.flags)
	if OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES3:
		albedo_srgb_texture.create_from_image(albedo_image, albedo_srgb_texture.flags)
	emit_signal("albedo_texture_changed", albedo_texture)


func set_height_image(image: Image, empty_data: bool = false) -> void:
	height_image = image
	height_texture.create_from_image(height_image, height_texture.flags)
	emit_signal("height_texture_changed", height_texture, empty_data)


func set_normal_image(value: Image, _path: String = "") -> void:
	normal_image = value
	normal_texture.create_from_image(normal_image, normal_texture.flags)
	emit_signal("normal_texture_changed", normal_texture)


func clear_maps() -> void:
	HeightDrawer.clear_all()
	height_image.lock()
	height_image.fill(Color.black)
	height_image.unlock()
	history.push_revision(height_image)


func resize_maps(size: Vector2) -> void:
	if height_image.get_size() != size:
		height_image.resize(int(size.x), int(size.y))
		set_height_image(height_image)
		history.push_revision(height_image)


func _on_height_image_loaded(value: Image, _path: String = "") -> void:
	value.convert(MapTypes.HEIGHT_IMAGE_FORMAT)
	set_height_image(value)


func _on_history_revision_changed(revision) -> void:
	height_image.copy_from(revision.heightmap)
	set_height_image(height_image)


func _try_find_height_image_in_dir(dirname: String, basename: String) -> Image:
	var dir := Directory.new()
	var img = Image.new()
	if dir.open(dirname) == OK:
		var possible_basenames = {
			basename + "_h": true,
			basename + "_height": true,
		}
		var _err = dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.get_basename() in possible_basenames:
				_err = img.load(dirname.plus_file(filename))
				break
			filename = dir.get_next()
		dir.list_dir_end()
	return img
