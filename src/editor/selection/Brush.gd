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
export(int) var size: int = 8

func get_coordinates(position: Vector2, bounds_size: Vector2) -> PoolVector3Array:
	return get_brush_coordinates(position, bounds_size, format, size, easing)

func get_affected_coordinates(position: Vector2, bounds_size: Vector2) -> PoolVector3Array:
	return get_brush_coordinates(position, bounds_size, format, size + 2, easing)

static func get_brush_coordinates(position: Vector2, bounds_size: Vector2, format_: int, size_: int, easing_: int) -> PoolVector3Array:
	var array = PoolVector3Array()
	var bounds = Rect2(Vector2.ZERO, bounds_size - Vector2.ONE)
	if size_ <= 1:
		array.append(Vector3(position.x, position.y, 0))
	else:
		var ease_param = easing_to_param(easing_)
		var half_size = int(size_ * 0.5)
		for x in range(-half_size, half_size + 1):
			for y in range(-half_size, half_size + 1):
				var delta = Vector2(x, y)
				var pos = position + delta
				var pos_distance = delta.length()
				if bounds.has_point(pos) and (format_ == Format.SQUARE or pos_distance < half_size):
					var z = clamp(1 - ease(pos_distance / half_size, ease_param), 0, 1)
					array.append(Vector3(pos.x, pos.y, z))
	return array


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
	
