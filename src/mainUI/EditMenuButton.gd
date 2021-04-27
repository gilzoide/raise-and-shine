# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends MenuButton

enum {
	UNDO,
	REDO,
	_SEPARATOR_0,
	BRUSH_SIZE_INCREASE,
	BRUSH_SIZE_DECREASE,
	BRUSH_PRESSURE_INCREASE,
	BRUSH_PRESSURE_DECREASE,
	BRUSH_ANGLE_INCREASE,
	BRUSH_ANGLE_DECREASE,
	_SEPARATOR_1,
	RESIZE_MAPS,
}

export(Resource) var history = preload("res://editor/undo/UndoHistory.tres")
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")
export(NodePath) var brush_toolbar_path

var SizePickerPopup: PackedScene = null

onready var _brush_toolbar = get_node(brush_toolbar_path)
onready var menu_popup = get_popup()


func _ready() -> void:
	menu_popup.add_item("Undo", UNDO)
	menu_popup.set_item_shortcut(UNDO, preload("res://shortcuts/UndoShortcut.tres"))
	menu_popup.add_item("Redo", REDO)
	menu_popup.set_item_shortcut(REDO, preload("res://shortcuts/RedoShortcut.tres"))
	
	menu_popup.add_separator()  # _SEPARATOR_0
	
	menu_popup.add_item("Increase brush size", BRUSH_SIZE_INCREASE)
	menu_popup.set_item_shortcut(BRUSH_SIZE_INCREASE, preload("res://shortcuts/BrushSizeIncrease_shortcut.tres"))
	menu_popup.set_item_shortcut_disabled(BRUSH_SIZE_INCREASE, true)  # shortcut is handled elsewhere
	menu_popup.add_item("Decrease brush size", BRUSH_SIZE_DECREASE)
	menu_popup.set_item_shortcut(BRUSH_SIZE_DECREASE, preload("res://shortcuts/BrushSizeDecrease_shortcut.tres"))
	menu_popup.set_item_shortcut_disabled(BRUSH_SIZE_DECREASE, true)  # shortcut is handled elsewhere
	
	menu_popup.add_item("Increase brush pressure", BRUSH_PRESSURE_INCREASE)
	menu_popup.set_item_shortcut(BRUSH_PRESSURE_INCREASE, preload("res://shortcuts/BrushPressureIncrease_shortcut.tres"))
	menu_popup.set_item_shortcut_disabled(BRUSH_PRESSURE_INCREASE, true)  # shortcut is handled elsewhere
	menu_popup.add_item("Decrease brush pressure", BRUSH_PRESSURE_DECREASE)
	menu_popup.set_item_shortcut(BRUSH_PRESSURE_DECREASE, preload("res://shortcuts/BrushPressureDecrease_shortcut.tres"))
	menu_popup.set_item_shortcut_disabled(BRUSH_PRESSURE_DECREASE, true)  # shortcut is handled elsewhere
	
	menu_popup.add_item("Increase brush angle", BRUSH_ANGLE_INCREASE)
	menu_popup.set_item_shortcut(BRUSH_ANGLE_INCREASE, preload("res://shortcuts/BrushAngleIncrease_shortcut.tres"))
	menu_popup.set_item_shortcut_disabled(BRUSH_ANGLE_INCREASE, true)  # shortcut is handled elsewhere
	menu_popup.add_item("Decrease brush angle", BRUSH_ANGLE_DECREASE)
	menu_popup.set_item_shortcut(BRUSH_ANGLE_DECREASE, preload("res://shortcuts/BrushAngleDecrease_shortcut.tres"))
	menu_popup.set_item_shortcut_disabled(BRUSH_ANGLE_DECREASE, true)  # shortcut is handled elsewhere
	
	menu_popup.add_separator()  # _SEPARATOR_1
	
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
	elif id == BRUSH_SIZE_INCREASE:
		_brush_toolbar.size_editor.scroll_range(1)
	elif id == BRUSH_SIZE_DECREASE:
		_brush_toolbar.size_editor.scroll_range(-1)
	elif id == BRUSH_PRESSURE_INCREASE:
		_brush_toolbar.pressure_editor.scroll_range(1)
	elif id == BRUSH_PRESSURE_DECREASE:
		_brush_toolbar.pressure_editor.scroll_range(-1)
	elif id == BRUSH_ANGLE_INCREASE:
		_brush_toolbar.angle_editor.scroll_range(1)
	elif id == BRUSH_ANGLE_DECREASE:
		_brush_toolbar.angle_editor.scroll_range(-1)
	elif id == RESIZE_MAPS:
		if SizePickerPopup == null:
			SizePickerPopup = load("res://mainUI/SizePickerPopup.tscn")
		var popup = SizePickerPopup.instance()
		add_child(popup)
		var _err = popup.connect("size_confirmed", project, "resize_maps", [], CONNECT_ONESHOT)
		_err = popup.connect("popup_hide", popup, "queue_free", [], CONNECT_ONESHOT)
		popup.popup_with_size(HeightDrawer.size)


func _on_menu_popup_about_to_show() -> void:
	menu_popup.set_item_disabled(UNDO, not history.can_undo())
	menu_popup.set_item_disabled(REDO, not history.can_redo())
