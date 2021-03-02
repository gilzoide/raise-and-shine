extends Resource

enum Format {
	CIRCLE,
	SQUARE,
}

export(Format) var format = Format.CIRCLE
export(int) var size: int = 8

func get_coordinates(position: Vector2, bounds_size: Vector2) -> PoolVector2Array:
	return get_brush_coordinates(position, bounds_size, format, size)

static func get_brush_coordinates(position: Vector2, bounds_size: Vector2, format: int, size: int) -> PoolVector2Array:
	var array = PoolVector2Array()
	var bounds = Rect2(Vector2.ZERO, bounds_size)
	var half_size = int(size / 2)
	for x in range(-half_size, half_size + 1):
		for y in range(-half_size, half_size + 1):
			var delta = Vector2(x, y)
			var pos = position + delta
			if bounds.has_point(pos) and (format == Format.SQUARE or delta.length() < half_size):
				array.append(pos)
	return array
