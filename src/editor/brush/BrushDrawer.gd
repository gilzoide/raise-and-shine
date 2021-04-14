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
	_update_size()
	brush.connect("changed", self, "_on_brush_changed")


func _on_brush_changed() -> void:
	_update_size()


func _update_size() -> void:
	var side = max(minimum_size, brush.size)
	size = Vector2(side, side)
	_brush_canvas_item.rect_size = size
	_brush_canvas_item.update()
