# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Viewport

export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")
export(int) var minimum_size = 128

var _border_spacing: float
onready var _brush_canvas_item = $BrushCanvasItem

func _ready() -> void:
	_on_brush_changed()
	brush.connect("changed", self, "_on_brush_changed")


func _on_brush_changed() -> void:
	_update_size()
	_brush_canvas_item.update()
	render_target_update_mode = Viewport.UPDATE_ONCE


func _update_size() -> void:
	var side = max(minimum_size, brush.size)
	if side != size.x:
		size = Vector2(side, side)
		_brush_canvas_item.rect_size = size
