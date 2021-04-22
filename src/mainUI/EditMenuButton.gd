# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends MenuButton

enum {
	UNDO,
	REDO,
	_SEPARATOR_0,
	RESIZE_MAPS,
}

export(Resource) var history = preload("res://editor/undo/UndoHistory.tres")
export(Resource) var selection = preload("res://editor/selection/ActiveSelection.tres")
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")

var _size_picker_popup: Popup = null

onready var menu_popup = get_popup()


func _ready() -> void:
	menu_popup.add_item("Undo", UNDO)
	menu_popup.set_item_shortcut(UNDO, preload("res://shortcuts/UndoShortcut.tres"))
	menu_popup.add_item("Redo", REDO)
	menu_popup.set_item_shortcut(REDO, preload("res://shortcuts/RedoShortcut.tres"))
	
	menu_popup.add_separator()
	menu_popup.add_item("Resize maps", RESIZE_MAPS)
	menu_popup.set_item_tooltip(RESIZE_MAPS, """
	Resize height and normal maps, scaling current content.
	""")
	
	menu_popup.connect("about_to_show", self, "_on_menu_popup_about_to_show")
	menu_popup.connect("id_pressed", self, "_on_menu_popup_id_pressed")


func call_undo() -> void:
	history.apply_undo()


func call_redo() -> void:
	history.apply_redo()


func _on_menu_popup_id_pressed(id: int) -> void:
	if id == UNDO:
		call_undo()
	elif id == REDO:
		call_redo()
	elif id == RESIZE_MAPS:
		if _size_picker_popup == null:
			_size_picker_popup = load("res://mainUI/SizePickerPopup.tscn").instance()
			add_child(_size_picker_popup)
		var _err = _size_picker_popup.connect("size_confirmed", project, "resize_maps", [], CONNECT_ONESHOT)
		_size_picker_popup.popup_with_size(HeightDrawer.size)


func _on_menu_popup_about_to_show() -> void:
	menu_popup.set_item_disabled(UNDO, not history.can_undo())
	menu_popup.set_item_disabled(REDO, not history.can_redo())
