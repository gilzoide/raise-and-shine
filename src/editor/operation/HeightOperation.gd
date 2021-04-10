# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource
class_name HeightOperation

const RADIAL_DIRECTION = NAN
const PIXEL_CENTER_OFFSET = Vector2(0.5, 0.5)

export(bool) var is_flat := true
export(float) var direction := RADIAL_DIRECTION

var bezier := CubicBezierCurve.new()

var cached_positions: PoolVector2Array
var cached_target: PoolVector2Array  # x is height index, y is easing depth
var cached_rect: Rect2
var is_easing_dirty := false

func _init() -> void:
	var _err = bezier.connect("changed", self, "_on_bezier_changed")


func set_direction(value: float) -> void:
	is_easing_dirty = value != direction
	direction = value
	emit_signal("changed")


func set_flat(value: bool) -> void:
	is_easing_dirty = value != is_flat
	is_flat = value
	emit_signal("changed")


func cache_target_from_selection(image: Image) -> void:
	cached_positions.resize(0)
	cached_target.resize(0)
	var size = image.get_size()
	var stride = size.x
	var min_x = size.x
	var min_y = size.y
	var max_x = -1
	var max_y = -1
	image.lock()
	for x in size.x:
		for y in size.y:
			if image.get_pixel(x, y).r > 0.5:
				cached_positions.append(Vector2(x, y))
				var index = y * stride + x
				cached_target.append(Vector2(index, 1.0))
				min_x = min(x, min_x)
				min_y = min(y, min_y)
				max_x = max(x, max_x)
				max_y = max(y, max_y)
	image.unlock()
	cached_rect = Rect2(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
	if is_flat:
		is_easing_dirty = false
	else:
		recalculate_easing()


func recalculate_easing() -> void:
	if is_flat:
		for i in cached_target.size():
			var v = cached_target[i]
			v.y = 1.0
			cached_target[i] = v
	else:
		var half_size = cached_rect.size * 0.5
		var center = cached_rect.position + half_size
		var is_radial = is_radial_direction(direction)
		for i in cached_positions.size():
			var pos = cached_positions[i]
			var v = cached_target[i]
			var normalized_delta = (pos + PIXEL_CENTER_OFFSET - center) / half_size
			if is_radial:
				v.y = get_brush_depth(normalized_delta.length(), bezier)
			else:
				v.y = get_direction_depth(normalized_delta, bezier, direction)
			cached_target[i] = v
	is_easing_dirty = false


static func is_radial_direction(value: float) -> bool:
	return is_nan(value)


static func get_direction_depth(normalized_delta: Vector2, curve: CubicBezierCurve, direction: float) -> float:
	var delta_factor = -cos(direction - normalized_delta.angle())
	var percent_from_highest = delta_factor * normalized_delta.length() * 0.5 + 0.5
	return get_brush_depth(percent_from_highest, curve)


static func get_brush_depth(percent_from_highest: float, curve: CubicBezierCurve) -> float:
	return curve.interpolate(1.0 - clamp(percent_from_highest, 0, 1)).y


func _on_bezier_changed() -> void:
	is_easing_dirty = is_easing_dirty or not is_flat
	emit_signal("changed")
