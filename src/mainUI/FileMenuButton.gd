# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends MenuButton

enum {
	LOAD,
	RESIZE,
	EXPORT_HEIGHT,
	EXPORT_NORMAL,
	_SEPARATOR_0,
	QUIT,
}

export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")

var size_picker_popup: Popup = null


func _ready() -> void:
	var popup = get_popup()
	popup.add_item("Load texture", LOAD)
	popup.set_item_shortcut(LOAD, preload("res://shortcuts/FileLoad_shortcut.tres"))
	popup.set_item_tooltip(LOAD, """
	Load a texture to be used as albedo.
	Empty height and normal maps will be created with the same dimensions as the loaded texture.
	""")
	
	popup.add_item("Resize maps", RESIZE)
	
	popup.add_item("Export height map", EXPORT_HEIGHT)
	popup.add_item("Export normal map", EXPORT_NORMAL)
	
	if OS.get_name() != "HTML5":
		popup.add_separator()
		popup.add_item("Quit", QUIT)
		popup.set_item_shortcut(QUIT, load("res://shortcuts/Quit_shortcut.tres"))
		popup.set_item_tooltip(QUIT, "Quit the application.")
	popup.connect("id_pressed", self, "_on_item_pressed")


func _on_item_pressed(id: int) -> void:
	if id == LOAD:
		project.load_project_dialog()
	elif id == RESIZE:
		if size_picker_popup == null:
			size_picker_popup = load("res://mainUI/SizePickerPopup.tscn").instance()
			add_child(size_picker_popup)
		var _err = size_picker_popup.connect("size_confirmed", project, "resize_maps", [], CONNECT_ONESHOT)
		size_picker_popup.popup_with_size(project.height_image.get_size())
	elif id == EXPORT_HEIGHT:
		project.save_image_dialog(MapTypes.Type.HEIGHT_MAP)
	elif id == EXPORT_NORMAL:
		project.save_image_dialog(MapTypes.Type.NORMAL_MAP)
	elif id == QUIT:
		get_tree().quit()
