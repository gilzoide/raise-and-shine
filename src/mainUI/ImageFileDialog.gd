# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Node

signal image_loaded(image)

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

onready var file_dialog = $FileDialog
onready var drop_dialog = $DropDialog
var success_method: FuncRef
var image_to_save: Image
var hovering = false


func _ready() -> void:
	var _err = get_tree().connect("files_dropped", self, "_on_files_dropped")


func try_load_image(on_success_method: FuncRef) -> void:
	success_method = on_success_method
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


func _on_file_selected(path: String) -> void:
	Input.set_default_cursor_shape(Input.CURSOR_WAIT)
	if file_dialog.mode == FileDialog.MODE_OPEN_FILE:
		var img = Image.new()
		if img.load(path) == OK:
			emit_signal("image_loaded", img)
			if success_method:
				success_method.call_func(img, path)
		else:
			_show_toast("Failed to load image =(")
	elif file_dialog.mode == FileDialog.MODE_SAVE_FILE:
		var res = ERR_FILE_UNRECOGNIZED
		if path.ends_with(".png"):
			res = image_to_save.save_png(path)
		elif path.ends_with(".exr"):
			res = image_to_save.save_exr(path)
		if res != OK:
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
	success_method = null
	image_to_save = null
	hovering = false
