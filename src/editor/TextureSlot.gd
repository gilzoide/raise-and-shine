# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

signal drag_started(button_index, uv)
signal drag_moved(relative_motion, uv)
signal drag_ended()

enum Type {
	ALBEDO_MAP,
	HEIGHT_MAP,
	NORMAL_MAP,
}

enum {
	TOGGLE_FILTER,
	LOAD_IMAGE,
	SAVE_IMAGE_AS,
}

export(Type) var type
export(float) var drag_height_speed = 0.01
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")
export(Resource) var selection = preload("res://editor/selection/ActiveSelection.tres")
export(Resource) var drag_operation = preload("res://editor/operation/DragOperation.tres")
export(Resource) var history = preload("res://editor/undo/UndoHistory.tres")

onready var title_menu_button = $Title
onready var menu_popup = title_menu_button.get_popup()
onready var texture_rect = $TextureRect


func _ready() -> void:
	title_menu_button.text = MapTypes.map_name(type)
	texture_rect.texture = MapTypes.map_texture(type)
	if type == MapTypes.Type.ALBEDO_MAP:
		project.connect("albedo_texture_changed", self, "_on_texture_updated")
	elif type == MapTypes.Type.HEIGHT_MAP:
		project.connect("height_texture_changed", self, "_on_texture_updated")
	elif type == MapTypes.Type.NORMAL_MAP:
		project.connect("normal_texture_changed", self, "_on_texture_updated")
	
	menu_popup.add_check_item("Filter texture", TOGGLE_FILTER)
	update_filter_check_item()
	menu_popup.add_separator()
	menu_popup.add_item("Load...", LOAD_IMAGE)
	menu_popup.add_item("Save as...", SAVE_IMAGE_AS)
	menu_popup.hide_on_checkable_item_selection = false
	menu_popup.connect("id_pressed", self, "_on_menu_id_pressed")


func _on_menu_id_pressed(id: int) -> void:
	if id == TOGGLE_FILTER:
		texture_rect.texture.flags ^= Texture.FLAG_FILTER
		update_filter_check_item()
	elif id == LOAD_IMAGE:
		project.load_image_dialog(type)
	elif id == SAVE_IMAGE_AS:
		project.save_image_dialog(type)


func _on_texture_updated(texture: Texture) -> void:
	texture_rect.texture = texture
	texture_rect.update()


func update_filter_check_item() -> void:
	menu_popup.set_item_checked(TOGGLE_FILTER, texture_rect.texture.flags & Texture.FLAG_FILTER)


func _on_TextureRect_drag_started(button_index: int, uv: Vector2) -> void:
	emit_signal("drag_started", button_index, uv)


func _on_TextureRect_drag_ended() -> void:
	emit_signal("drag_ended")


func _on_TextureRect_drag_moved(relative_motion: Vector2, uv: Vector2) -> void:
	emit_signal("drag_moved", relative_motion, uv)
