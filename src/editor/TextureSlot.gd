# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

enum Type {
	ALBEDO_MAP,
	HEIGHT_MAP,
	NORMAL_MAP,
}

export(Type) var type
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")
export(Resource) var selection = preload("res://editor/selection/ActiveSelection.tres")

onready var texture_rect = $TextureRect
var textures

var _dragging := false

func _ready() -> void:
	textures = MapTypes.map_textures(type)
	texture_rect.texture = textures[0]
	if type == MapTypes.Type.ALBEDO_MAP:
		project.connect("albedo_texture_changed", self, "_on_texture_updated")
	elif type == MapTypes.Type.HEIGHT_MAP:
		project.connect("height_texture_changed", self, "_on_texture_updated")
	elif type == MapTypes.Type.NORMAL_MAP:
		project.connect("normal_texture_changed", self, "_on_texture_updated")


func _on_texture_updated(_texture: Texture, _empty_data: bool = false) -> void:
	texture_rect.update()


func _on_TextureRect_drag_started(button_index: int, uv: Vector2) -> void:
	_dragging = true
	ControlExtras.set_cursor(self, selection.get_cursor_for_active_tool())
	selection.set_drag_operation_started(button_index, uv)


func _on_TextureRect_drag_ended() -> void:
	_dragging = false
	ControlExtras.set_cursor(self, Control.CURSOR_ARROW)
	selection.set_drag_operation_ended()


func _on_TextureRect_drag_moved(relative_motion: Vector2, uv: Vector2) -> void:
	if _dragging:
		selection.set_drag_hovering(relative_motion, uv)
