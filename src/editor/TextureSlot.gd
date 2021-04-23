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
export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")

onready var texture_rect = $TextureRect
onready var _brush_hover = $BrushHover2D
var textures

var _dragging := false

func _ready() -> void:
	textures = MapTypes.map_textures(type)
	texture_rect.texture = textures[0]
	
	var _err
	if type == MapTypes.Type.ALBEDO_MAP:
		_err = project.connect("albedo_texture_changed", self, "_on_drawn_texture_updated")
	elif type == MapTypes.Type.HEIGHT_MAP:
		_err = HeightDrawer.connect("size_changed", self, "_on_drawn_texture_updated")
	elif type == MapTypes.Type.NORMAL_MAP:
		_err = NormalDrawer.connect("size_changed", self, "_on_drawn_texture_updated")
	_err = HeightDrawer.connect("size_changed", self, "_recalculate_brush_scale")
	
	_err = texture_rect.connect("draw", self, "_recalculate_brush_scale", [], CONNECT_DEFERRED)
	_err = brush.connect("size_changed", self, "_on_brush_size_changed")
	_err = brush.connect("changed", self, "_on_brush_changed")


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		brush.visible = true
	elif what == NOTIFICATION_MOUSE_EXIT or what == NOTIFICATION_WM_MOUSE_EXIT:
		brush.visible = false


func _on_drawn_texture_updated(_texture: Texture = null, _empty_data: bool = false) -> void:
	texture_rect.update()
	_recalculate_brush_scale()


func _on_TextureRect_drag_started(button_index: int, uv: Vector2) -> void:
	_dragging = true
	BrushDrawer.erasing = button_index == BUTTON_RIGHT
	HeightDrawer.draw_brush_centered_uv(brush, uv)


func _on_TextureRect_drag_ended() -> void:
	if _dragging:
		_dragging = false
		BrushDrawer.erasing = false
		HeightDrawer.cancel_draw()
		HeightDrawer.take_snapshot()


func _on_TextureRect_drag_moved(uv: Vector2) -> void:
	brush.uv = uv
	if _dragging:
		HeightDrawer.draw_brush_centered_uv(brush, uv)


func _on_brush_size_changed() -> void:
	_recalculate_brush_scale()


func _recalculate_brush_scale() -> void:
	var texture_pixel_size = texture_rect.drawn_rect.size / HeightDrawer.size
	_brush_hover.scale = Vector2(brush.size, brush.size) * texture_pixel_size


func _on_brush_changed() -> void:
	_brush_hover.visible = brush.visible
	if _brush_hover.visible:
		var drawn_rect = texture_rect.drawn_rect
		_brush_hover.position = drawn_rect.position + brush.uv * drawn_rect.size
		_brush_hover.rotation_degrees = brush.angle
