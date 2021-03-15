# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

enum Operation {
	INCREASE_BY,
	DECREASE_BY,
	SET_VALUE,
}

enum Easing {
	FLAT,
	LINEAR,
	EASE_IN,
	EASE_OUT,
	EASE_INOUT,
	CIRCULAR_IN,
	CIRCULAR_OUT,
}

const RADIAL_DIRECTION = NAN
const PIXEL_CENTER_OFFSET = Vector2(0.5, 0.5)

export(Operation) var type = Operation.INCREASE_BY
export(float) var amount = 0.1
export(Easing) var easing = Easing.FLAT
export(float) var direction = RADIAL_DIRECTION


func apply(heightmap: HeightMapData, mask: BitMap, rect: Rect2) -> void:
	offset_by(heightmap, mask, rect, amount)


func offset_by(heightmap: HeightMapData, mask: BitMap, rect: Rect2, value: float) -> void:
	var ease_func = easing_func(easing)
	var half_size = rect.size * 0.5
	var center = rect.position + half_size
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var v = Vector2(x, y)
			if mask.get_bit(v):
				var height = heightmap.get_value(x, y)
				var depth
				if easing == Easing.FLAT:
					depth = 1.0
				else:
					var normalized_delta = (v + PIXEL_CENTER_OFFSET - center) / half_size
					if is_radial_direction(direction):
						depth = get_brush_depth(normalized_delta.length(), ease_func)
					else:
						depth = get_direction_depth(normalized_delta, ease_func, direction)
				height = clamp(height + value * depth, 0, 1)
				heightmap.set_value(x, y, height)


func easing_func(easing_: int) -> FuncRef:
	if easing_ == Easing.FLAT:
		return funcref(self, "flat")
	elif easing_ == Easing.LINEAR:
		return funcref(self, "ease_linear")
	elif easing_ == Easing.EASE_IN:
		return funcref(self, "ease_in")
	elif easing_ == Easing.EASE_OUT:
		return funcref(self, "ease_out")
	elif easing_ == Easing.EASE_INOUT:
		return funcref(self, "ease_inout")
	elif easing_ == Easing.CIRCULAR_IN:
		return funcref(self, "ease_in_circular")
	elif easing_ == Easing.CIRCULAR_OUT:
		return funcref(self, "ease_out_circular")
	else:
		assert(false, "FIXME!!!")
		return null


static func is_radial_direction(value: float) -> bool:
	return is_nan(value)


static func get_direction_depth(normalized_delta: Vector2, ease_func: FuncRef, direction_: float) -> float:
	var delta_factor = -cos(direction_ - normalized_delta.angle())
	var percent_from_highest = delta_factor * normalized_delta.length() * 0.5 + 0.5
	return get_brush_depth(percent_from_highest, ease_func)


static func get_brush_depth(percent_from_highest: float, ease_func: FuncRef) -> float:
	return 1 - ease_func.call_func(clamp(percent_from_highest, 0, 1))


static func flat(_p: float) -> float:
	return 0.0


static func ease_linear(p: float) -> float:
	return p


static func ease_in(p: float) -> float:
	return ease(p, 0.5)


static func ease_out(p: float) -> float:
	return ease(p, 2.0)


static func ease_inout(p: float) -> float:
	return ease(p, -2.0)


static func ease_in_circular(p: float) -> float:
	return 1 - sqrt(1 - (p * p))


static func ease_out_circular(p: float) -> float:
	return sqrt((2 - p) * p)
