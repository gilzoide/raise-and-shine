# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Viewport

export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")
onready var canvas_item = $BrushCanvasItem


func _ready() -> void:
	brush.connect("parameter_changed", self, "redraw")
	brush.connect("selection_rect_changed", self, "redraw_rect")


func redraw_rect(rect: Rect2 = Rect2(Vector2.ZERO, size)) -> void:
	canvas_item.selection_rect = rect
	redraw()


func redraw() -> void:
	render_target_update_mode = Viewport.UPDATE_ONCE
	canvas_item.update()
