# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Viewport

export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")
export(int) var minimum_size = 128

var _canvas_item


func _ready() -> void:
	_canvas_item = VisualServer.canvas_item_create()
	VisualServer.canvas_item_set_parent(_canvas_item, find_world_2d().canvas)
	
	_on_brush_changed()
	brush.connect("changed", self, "_on_brush_changed")


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		VisualServer.free_rid(_canvas_item)


func _on_brush_changed() -> void:
	_update_size()
	var color = Color(brush.depth, brush.depth, brush.depth)
	VisualServer.canvas_item_add_rect(_canvas_item, Rect2(Vector2.ZERO, size), color)
	render_target_update_mode = Viewport.UPDATE_ONCE


func _update_size() -> void:
	var side = max(minimum_size, brush.size)
	if side != size.x:
		size = Vector2(side, side)
