# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends MenuButton

enum {
	UNDO,
	REDO,
	_SEPARATOR_0,
	SELECTION_CLEAR,
	SELECTION_ALL,
	SELECTION_INVERT,
}

export(Resource) var history = preload("res://editor/undo/UndoHistory.tres")
export(Resource) var selection = preload("res://editor/selection/ActiveSelection.tres")

onready var menu_popup = get_popup()


func _ready() -> void:
	menu_popup.add_item("Undo", UNDO)
	menu_popup.set_item_shortcut(UNDO, preload("res://shortcuts/UndoShortcut.tres"))
	menu_popup.add_item("Redo", REDO)
	menu_popup.set_item_shortcut(REDO, preload("res://shortcuts/RedoShortcut.tres"))
	menu_popup.add_separator()
	menu_popup.add_item("Clear selection", SELECTION_CLEAR)
	menu_popup.set_item_shortcut(SELECTION_CLEAR, preload("res://shortcuts/SelectionClear_shortcut.tres"))
	menu_popup.add_item("Select all", SELECTION_ALL)
	menu_popup.set_item_shortcut(SELECTION_ALL, preload("res://shortcuts/SelectionAll_shortcut.tres"))
	menu_popup.add_item("Invert selection", SELECTION_INVERT)
	menu_popup.set_item_shortcut(SELECTION_INVERT, preload("res://shortcuts/SelectionInvert_shortcut.tres"))
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
	elif id == SELECTION_CLEAR:
		selection.clear(false)
	elif id == SELECTION_ALL:
		selection.clear(true)
	elif id == SELECTION_INVERT:
		selection.invert()


func _on_menu_popup_about_to_show() -> void:
	menu_popup.set_item_disabled(UNDO, not history.can_undo())
	menu_popup.set_item_disabled(REDO, not history.can_redo())
