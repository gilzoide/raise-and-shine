# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Node

const OPEN_FILTERS = [
	"*.bmp ; BMP",
	"*.dds ; DirectDraw Surface",
	"*.exr ; OpenEXR",
	"*.hdr ; Radiance HDR",
	"*.jpg ; JPG",
	"*.jpeg ; JPEG",
	"*.png ; PNG",
	"*.tga ; Truevision Targa",
	"*.webp ; WebP",
]
const SAVE_FILTERS = [
	"*.exr ; OpenEXR",
	"*.png ; PNG",
]
const OPEN_EXTENSIONS = PoolStringArray([
	"bmp",
	"dds",
	"exr",
	"hdr",
	"jpg",
	"jpeg",
	"png",
	"tga",
	"webp",
])

const OPEN_TEXT = "You can also drop files to this window\n"
const SAVE_TEXT = ""

export(Resource) var dispatch_queue = preload("res://mainUI/loading/LoadImage_dispatchqueue.tres")

var image_to_save: Image
var _success_method: FuncRef
onready var file_dialog = $FileDialog
onready var drop_dialog = $DropDialog
onready var _loading_overlay = $LoadingOverlay


func _ready() -> void:
	var _err = get_tree().connect("files_dropped", self, "_on_files_dropped")


func try_load_image(success_method: FuncRef) -> void:
	_success_method = success_method
	if OS.get_name() != "HTML5":
		file_dialog.mode = FileDialog.MODE_OPEN_FILE
		file_dialog.filters = OPEN_FILTERS
		file_dialog.dialog_text = OPEN_TEXT
		file_dialog.popup_centered_ratio()
	else:
		drop_dialog.popup_centered_ratio()


func try_save_image(image: Image, filename: String) -> void:
	if OS.get_name() != "HTML5":
		image_to_save = image
		file_dialog.mode = FileDialog.MODE_SAVE_FILE
		file_dialog.filters = SAVE_FILTERS
		file_dialog.dialog_text = SAVE_TEXT
		file_dialog.current_file = filename
		file_dialog.popup_centered_ratio()
	else:
		var bytes = image.save_png_to_buffer()
		var base64 = Marshalls.raw_to_base64(bytes)
		var uri = "data:image/png;base64," + base64
		if OS.has_feature("JavaScript"):
			JavaScript.eval("""
				function download(dataurl, filename) {
					var a = document.createElement('a');
					a.href = dataurl;
					a.setAttribute('download', filename);
					a.click();
				}
				download('%s', '%s');
			""" % [uri, filename])
		elif OS.shell_open(uri) != OK:
			_show_toast("Failed to save image =(")


func save_current_images(heightmap: Image, heightmap_path: String, normalmap: Image, normalmap_path: String) -> bool:
	var group = dispatch_queue.dispatch_group([
		[self, "_save_image", [heightmap, heightmap_path]],
		[self, "_save_image", [normalmap, normalmap_path]],
	])
	var results = yield(group, "finished")
	var message = "%s\n%s" % [
		"Height map saved at \"%s\"" % heightmap_path if results[0] == OK else "Failed saving height map",
		"Normal map saved at \"%s\"" % normalmap_path if results[1] == OK else "Failed saving normal map",
	]
	_show_toast(message)
	return results[0] == OK and results[1] == OK


func _save_image(image: Image, path: String) -> int:
	var res = ERR_FILE_UNRECOGNIZED
	if path.ends_with(".png"):
		res = image.save_png(path)
	elif path.ends_with(".exr"):
		res = image.save_exr(path)
	return res


func _on_file_selected(path: String) -> void:
	Input.set_default_cursor_shape(Input.CURSOR_WAIT)
	if file_dialog.mode == FileDialog.MODE_OPEN_FILE:
		if dispatch_queue.is_threaded():
			_loading_overlay.visible = true
			dispatch_queue.dispatch(self, "_load_image_from_path", [path, _success_method]).then_deferred(self, "_on_load_image_finished")
		else:
			var image = _load_image_from_path(path, _success_method)
			_on_load_image_finished(image)
	elif file_dialog.mode == FileDialog.MODE_SAVE_FILE:
		if _save_image(image_to_save, path) == OK:
			_show_toast("Image saved at \"%s\"" % path)
		else:
			_show_toast("Failed to save image =(")
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_files_dropped(files: PoolStringArray, _screen: int) -> void:
	if file_dialog.visible or drop_dialog.visible:
		for f in files:
			if f.get_extension() in OPEN_EXTENSIONS:
				_on_file_selected(f)
				file_dialog.hide()
				drop_dialog.hide()
				return
		var err_msg = "Invalid image file\nRecognized extensions: %s" % OPEN_EXTENSIONS.join(', ')
		_show_toast(err_msg)


func _show_toast(msg: String) -> void:
	var toast = Toast.new(msg, Toast.LENGTH_LONG)
	add_child(toast)
	toast.show()


func _on_popup_hide() -> void:
	file_dialog.deselect_items()
	_success_method = null
	image_to_save = null


func _load_image_from_path(path: String, success_method: FuncRef) -> Image:
	var img = Image.new()
	if img.load(path) == OK:
		if success_method:
			success_method.call_func(img, path)
	return img


func _on_load_image_finished(image: Image) -> void:
	_show_toast("Failed to load image =(" if image.is_empty() else "Image loaded")
	_loading_overlay.visible = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
