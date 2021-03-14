# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends MenuButton

enum {
	LOAD,
	RESIZE,
	QUIT,
}

export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")

var size_picker_popup: Popup = null


func _ready() -> void:
	var popup = get_popup()
	popup.add_item("Load", LOAD)
	popup.set_item_shortcut(LOAD, preload("res://shortcuts/FileLoad_shortcut.tres"))
	
	popup.add_item("Resize maps", RESIZE)
	
	if OS.get_name() != "HTML5":
		popup.add_item("Quit", QUIT)
		popup.set_item_shortcut(QUIT, load("res://shortcuts/Quit_shortcut.tres"))
	popup.connect("id_pressed", self, "_on_item_pressed")


func _on_item_pressed(id: int) -> void:
	if id == LOAD:
		pass
	elif id == RESIZE:
		if size_picker_popup == null:
			size_picker_popup = load("res://mainUI/SizePickerPopup.tscn").instance()
			add_child(size_picker_popup)
		var _err = size_picker_popup.connect("size_confirmed", project, "resize_maps", [], CONNECT_ONESHOT)
		size_picker_popup.popup_with_size(project.height_image.get_size())
	elif id == QUIT:
		get_tree().quit()
