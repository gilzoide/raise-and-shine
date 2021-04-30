# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends MenuButton

enum {
	LOAD,
	SAVE,
	LOAD_HEIGHT,
#	LOAD_NORMAL,
	EXPORT,
	QUIT,
}

export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")

var ExportMenuPopup
onready var popup = get_popup()

func _ready() -> void:
	popup.add_item("Open image...", LOAD)
	popup.set_item_shortcut(popup.get_item_index(LOAD), load("res://shortcuts/FileLoad_shortcut.tres"))
	popup.set_item_tooltip(popup.get_item_index(LOAD), """
	Open image to be used as albedo.
	Empty height and normal maps will be created with the same dimensions as the loaded image.
	""")
	
	if ProjectSettings.get_setting("global/file_menu_have_save"):
		popup.add_item("Save", SAVE)
		popup.set_item_disabled(popup.get_item_index(SAVE), true)
		popup.set_item_shortcut(popup.get_item_index(SAVE), load("res://shortcuts/FileSave_shortcut.tres"))
		popup.set_item_tooltip(popup.get_item_index(SAVE), """
		Save height and normal map images to the same directory as loaded image.
		Height map will have "_height" appended to the loaded image name.
		Normal map will have "_normal" appended to the loaded image name.
		""")
		project.connect("albedo_texture_changed", self, "_on_project_albedo_texture_changed")
	
	popup.add_separator()
	
	popup.add_item("Load height map", LOAD_HEIGHT)
#	popup.add_item("Load normal map", LOAD_NORMAL)
	popup.add_item("Export...", EXPORT)
	popup.set_item_shortcut(popup.get_item_index(EXPORT), load("res://shortcuts/ExportMenu_shortcut.tres"))
	
	if ProjectSettings.get_setting("global/file_menu_have_quit"):
		popup.add_separator()
		popup.add_item("Quit", QUIT)
		popup.set_item_shortcut(popup.get_item_index(QUIT), load("res://shortcuts/Quit_shortcut.tres"))
		popup.set_item_tooltip(popup.get_item_index(QUIT), "Quit the application.")
	popup.connect("id_pressed", self, "_on_item_pressed")


func _on_item_pressed(id: int) -> void:
	if id == LOAD:
		project.load_project_dialog()
	elif id == SAVE:
		project.save_current()
	elif id == LOAD_HEIGHT:
		project.load_image_dialog(MapTypes.Type.HEIGHT_MAP)
#	elif id == LOAD_NORMAL:
#		project.load_image_dialog(MapTypes.Type.NORMAL_MAP)
	elif id == EXPORT:
		if not ExportMenuPopup:
			ExportMenuPopup = load("res://mainUI/ExportMenuPopup.tscn")
		var popup: Popup = ExportMenuPopup.instance()
		add_child(popup)
		var _err = popup.connect("popup_hide", popup, "queue_free", [], CONNECT_ONESHOT)
		popup.popup_centered_ratio()
	elif id == QUIT:
		get_tree().quit()


func _on_project_albedo_texture_changed(_texture) -> void:
	popup.set_item_disabled(popup.get_item_index(SAVE), false)
