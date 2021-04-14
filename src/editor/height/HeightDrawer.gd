# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Viewport

signal brush_drawn(rect)
signal cleared()

export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")

var _canvas_item = VisualServer.canvas_item_create()


func _ready() -> void:
	render_target_v_flip = true
	get_texture().flags = Texture.FLAG_FILTER
	
	_canvas_item = VisualServer.canvas_item_create()
	VisualServer.canvas_item_set_parent(_canvas_item, find_world_2d().canvas)
	
	_on_height_texture_changed(project.height_texture)
	project.connect("height_texture_changed", self, "_on_height_texture_changed")
	clear_all()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		VisualServer.free_rid(_canvas_item)


func draw_brush_centered_uv(brush, uv: Vector2) -> void:
	var position = (uv * size).floor()
	draw_brush_centered(brush, position)


func draw_brush_centered(brush, center: Vector2) -> void:
	var half_size = floor(brush.size * 0.5)
	var rect = Rect2(center - Vector2(half_size, half_size), Vector2(brush.size, brush.size))
	BrushDrawer.get_texture().draw_rect(_canvas_item, rect, false)
	render_target_update_mode = Viewport.UPDATE_ONCE
	yield(VisualServer, "frame_post_draw")
	emit_signal("brush_drawn", rect)


func clear_all(color = Color.black) -> void:
	VisualServer.canvas_item_add_rect(_canvas_item, Rect2(Vector2.ZERO, size), color)
	render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
	render_target_update_mode = Viewport.UPDATE_ONCE
	yield(VisualServer, "frame_post_draw")
	emit_signal("cleared")


func _on_height_texture_changed(texture: Texture, empty_data = false) -> void:
	var new_size = texture.get_size()
	if not new_size.is_equal_approx(size):
		size = new_size
	if empty_data:
		clear_all()
	else:
		texture.draw_rect(_canvas_item, Rect2(Vector2.ZERO, size), false)
		render_target_update_mode = Viewport.UPDATE_ONCE
