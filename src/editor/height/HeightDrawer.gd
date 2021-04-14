# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Viewport

export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")

onready var _clear_background = $Background
onready var _brush = $Brush


func _ready() -> void:
	_brush.texture = BrushDrawer.get_texture()
	get_texture().flags = Texture.FLAG_FILTER
	_on_height_texture_changed(project.height_texture)
	project.connect("height_texture_changed", self, "_on_height_texture_changed")
	clear_all()


func draw_brush_centered_uv(brush, uv: Vector2) -> void:
	var position = (uv * size).floor()
	draw_brush_centered(brush, position)


func draw_brush_centered(brush, center: Vector2) -> void:
	var half_size = floor(brush.size * 0.5)
	_brush.rect_position = center - Vector2(half_size, half_size)
	_brush.rect_size = Vector2(brush.size, brush.size)
	render_target_update_mode = Viewport.UPDATE_ONCE


func clear_all(color = Color.black) -> void:
	_clear_background.color = color
	_clear_background.visible = true
	render_target_update_mode = Viewport.UPDATE_ONCE
	yield(VisualServer, "frame_post_draw")
	_clear_background.visible = false


func _on_height_texture_changed(texture: Texture, _empty_data = false) -> void:
	var new_size = texture.get_size()
	if new_size.is_equal_approx(size):
		return
	size = new_size
	_clear_background.rect_size = new_size
	render_target_update_mode = Viewport.UPDATE_ONCE
