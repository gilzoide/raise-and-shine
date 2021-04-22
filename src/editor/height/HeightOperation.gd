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


func _init() -> void:
	var _err = bezier.connect("changed", self, "_on_bezier_changed")


func set_direction(value: float) -> void:
	direction = value
	emit_signal("changed")


func set_flat(value: bool) -> void:
	is_flat = value
	emit_signal("changed")


static func is_radial_direction(value: float) -> bool:
	return is_nan(value)


static func get_direction_depth(normalized_delta: Vector2, curve: CubicBezierCurve, direction: float) -> float:
	var delta_factor = -cos(direction - normalized_delta.angle())
	var percent_from_highest = delta_factor * normalized_delta.length() * 0.5 + 0.5
	return get_brush_depth(percent_from_highest, curve)


static func get_brush_depth(percent_from_highest: float, curve: CubicBezierCurve) -> float:
	return curve.interpolate(1.0 - clamp(percent_from_highest, 0, 1)).y


func _on_bezier_changed() -> void:
	emit_signal("changed")
