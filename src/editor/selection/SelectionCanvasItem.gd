# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
class_name SelectionCanvasItem

extends Control

const SELECTED_COLOR = Color.white
const UNSELECTED_COLOR = Color.black

enum Format {
	TEXTURE,
	RECTANGLE,
	ELLIPSE,
	LINE,
	PENCIL,
}

export(Format) var format = Format.TEXTURE
var texture: Texture
var points: PoolVector2Array
var line_direction: float


func _draw() -> void:
	if format == Format.TEXTURE:
		draw_texture(texture, Vector2.ZERO)
	elif format == Format.RECTANGLE:
		draw_rect(Rect2(Vector2.ZERO, rect_size), SELECTED_COLOR)
	elif format == Format.ELLIPSE:
		var center = rect_size * 0.5
		draw_set_transform(center, 0, center)
		draw_circle(Vector2.ZERO, 1, SELECTED_COLOR)
	elif format == Format.LINE:
		var from = Vector2.ZERO if line_direction >= 0 else Vector2(0, rect_size.y)
		var to = rect_size if line_direction >= 0 else Vector2(rect_size.x, 0)
		draw_line(from, to, SELECTED_COLOR)
	elif format == Format.PENCIL:
		draw_set_transform(-rect_position, 0, Vector2.ONE)
		draw_polyline(points, SELECTED_COLOR)


func paint_position(pos: Vector2) -> void:
	points.append(pos)
	if points.size() == 1:
		points.append(pos + Vector2.ONE)


func clear_positions() -> void:
	points.resize(0)


func set_selection_union(is_union: bool) -> void:
	if is_union:
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	else:
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
