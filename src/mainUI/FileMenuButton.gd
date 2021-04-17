# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends MenuButton

enum {
	LOAD,
	_SEPARATOR_0,
	LOAD_HEIGHT,
#	LOAD_NORMAL,
	_SEPARATOR_1,
	EXPORT_ALBEDO,
	EXPORT_HEIGHT,
	EXPORT_NORMAL,
	EXPORT_LIT,
	_SEPARATOR_2,
	QUIT,
}

export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")


func _ready() -> void:
	var popup = get_popup()
	popup.add_item("Open image...", LOAD)
	popup.set_item_shortcut(LOAD, preload("res://shortcuts/FileLoad_shortcut.tres"))
	popup.set_item_tooltip(LOAD, """
	Open image to be used as albedo.
	Empty height and normal maps will be created with the same dimensions as the loaded image.
	""")
	
	popup.add_separator()  # _SEPARATOR_0
	
	popup.add_item("Load height map", LOAD_HEIGHT)
#	popup.add_item("Load normal map", LOAD_NORMAL)
	
	popup.add_separator()  # _SEPARATOR_1
	
	popup.add_item("Export albedo map", EXPORT_ALBEDO)
	popup.add_item("Export height map", EXPORT_HEIGHT)
	popup.add_item("Export normal map", EXPORT_NORMAL)
	popup.add_item("Export illuminated texture", EXPORT_LIT)
	popup.set_item_tooltip(EXPORT_LIT, """
	Export illuminated texture preview the same way as it appears in the 2D visualization.
	""")
	
	if OS.get_name() != "HTML5":
		popup.add_separator()  # _SEPARATOR_2
		popup.add_item("Quit", QUIT)
		popup.set_item_shortcut(QUIT, load("res://shortcuts/Quit_shortcut.tres"))
		popup.set_item_tooltip(QUIT, "Quit the application.")
	popup.connect("id_pressed", self, "_on_item_pressed")


func _on_item_pressed(id: int) -> void:
	if id == LOAD:
		project.load_project_dialog()
	elif id == LOAD_HEIGHT:
		project.load_image_dialog(MapTypes.Type.HEIGHT_MAP)
#	elif id == LOAD_NORMAL:
#		project.load_image_dialog(MapTypes.Type.NORMAL_MAP)
	elif id == EXPORT_ALBEDO:
		project.save_image_dialog_type(MapTypes.Type.ALBEDO_MAP)
	elif id == EXPORT_HEIGHT:
		project.save_image_dialog_type(MapTypes.Type.HEIGHT_MAP)
	elif id == EXPORT_NORMAL:
		project.save_image_dialog_type(MapTypes.Type.NORMAL_MAP)
	elif id == EXPORT_LIT:
		PhotoBooth.take_screenshot()
	elif id == QUIT:
		get_tree().quit()
