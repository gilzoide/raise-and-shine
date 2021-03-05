extends Resource

enum Format {
	CIRCLE,
	SQUARE,
}

enum Easing {
	FLAT,
	LINEAR,
	EASE_IN,
	EASE_OUT,
	EASE_INOUT,
}

export(Format) var format = Format.CIRCLE
export(Easing) var easing = Easing.FLAT
export(float) var direction = NAN
export(int) var size: int = 8

func get_coordinates(position: Vector2, bounds_size: Vector2) -> PoolVector3Array:
	return get_brush_coordinates(position, bounds_size, size)

func get_affected_coordinates(position: Vector2, bounds_size: Vector2) -> PoolVector3Array:
	return get_brush_coordinates(position, bounds_size, size + 2)

func get_brush_coordinates(position: Vector2, bounds_size: Vector2, size_: float) -> PoolVector3Array:
	var array = PoolVector3Array()
	var bounds = Rect2(Vector2.ZERO, bounds_size)
	if size_ <= 1:
		array.append(Vector3(position.x, position.y, 1))
	else:
		var ease_param = easing_to_param(easing)
		var half_size = int(size_ * 0.5)
		for x in range(-half_size, half_size + 1):
			for y in range(-half_size, half_size + 1):
				var delta = Vector2(x, y)
				var pos = position + delta
				var normalized_delta = delta / half_size
				if bounds.has_point(pos) and (format == Format.SQUARE or normalized_delta.length_squared() <= 1.1):
					var z
					if is_nan(direction):
						z = get_brush_depth(normalized_delta.length(), ease_param)
					else:
						z = get_brush_direction_depth(normalized_delta, ease_param, direction)
					array.append(Vector3(pos.x, pos.y, z))
	return array


static func get_brush_direction_depth(normalized_delta: Vector2, ease_param: float, direction_: float) -> float:
	var delta_factor = -cos(direction_ - normalized_delta.angle())
	var percent_from_highest = delta_factor * normalized_delta.length() * 0.5 + 0.5
	return get_brush_depth(percent_from_highest, ease_param)

static func get_brush_depth(percent_from_highest: float, ease_param: float) -> float:
	return 1 - ease(percent_from_highest, ease_param)

static func easing_to_param(easing_: int) -> float:
	if easing_ == Easing.LINEAR:
		return 1.0
	elif easing_ == Easing.EASE_IN:
		return 0.5
	elif easing_ == Easing.EASE_OUT:
		return 2.0
	elif easing_ == Easing.EASE_INOUT:
		return -2.0
	else:  # FLAT
		return 0.0

