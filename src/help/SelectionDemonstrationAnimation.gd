# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

enum Modifier {
	NONE,
	SHIFT,
	CONTROL,
}

export(Modifier) var modifier = Modifier.NONE
export(Curve) var animation_curve: Curve = preload("res://help/SelectionDemonstrationAnimation_curve.tres")
export(float) var animation_duration = 2
export(Vector2) var starting_position = Vector2(0.5, 0.5)
export(Vector2) var end_position = Vector2(0.9, 0.7)

var _timer = 0

onready var _canvas_item = $SelectionCanvasItem
onready var _active_selection = $ActiveSelection
onready var _cursor = $CursorIcon

func _ready() -> void:
	_update_canvas_item_position()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_canvas_item_position()


func _process(delta: float) -> void:
	_timer += delta
	if _timer > animation_duration:
		_timer = fmod(_timer, animation_duration)
		_canvas_item.clear_positions()
	
	var percent = _timer / animation_duration
	
	var selection_start = starting_position * rect_size
	var size = (end_position - starting_position) * Vector2(percent, animation_curve.interpolate(percent)) * rect_size
	_cursor.position = selection_start + size
	
	if _canvas_item.format == _canvas_item.Format.PENCIL:
		_canvas_item.paint_position(_cursor.position)
	else:
		size = size.floor()
		if modifier == Modifier.SHIFT:
			_canvas_item.rect_position = selection_start - size
			size *= 2
		elif modifier == Modifier.CONTROL:
			size.x = min(size.x, size.y)
			size.y = size.x
		size.x = max(1.0, size.x)
		size.y = max(1.0, size.y)
		_canvas_item.rect_size = size
	_canvas_item.update()


func set_selection_union(is_union: bool) -> void:
	_canvas_item.set_selection_union(is_union)
	_active_selection.visible = not is_union


func set_format(format: int) -> void:
	_canvas_item.format = format
	_timer = 0


func _update_canvas_item_position() -> void:
	_canvas_item.rect_position = starting_position * rect_size
