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
	CIRCULAR_IN,
	CIRCULAR_OUT,
}

export(Format) var format = Format.CIRCLE
export(Easing) var easing = Easing.FLAT
export(float) var direction = NAN
export(int) var size: int = 8

func get_coordinates(position: Vector2, bounds_size: Vector2) -> PoolVector3Array:
	return get_brush_coordinates(position, bounds_size, size)

func get_affected_rect(position: Vector2, bounds_size: Vector2) -> Rect2:
	return get_brush_rect(position, bounds_size, size + 2)

func get_brush_rect(position: Vector2, bounds_size: Vector2, size_: float) -> Rect2:
	var half_size = int(size_ * 0.5)
	var bounds = Rect2(Vector2.ZERO, bounds_size)
	return Rect2(position - Vector2(half_size, half_size), Vector2(size_, size_)).clip(bounds)

func get_brush_coordinates(position: Vector2, bounds_size: Vector2, size_: float) -> PoolVector3Array:
	var array = PoolVector3Array()
	var bounds = Rect2(Vector2.ZERO, bounds_size)
	if size_ <= 1:
		array.append(Vector3(position.x, position.y, 1))
	else:
		var ease_func = easing_func(easing)
		var half_size = int(size_ * 0.5)
		for x in range(-half_size, half_size + 1):
			for y in range(-half_size, half_size + 1):
				var delta = Vector2(x, y)
				var pos = position + delta
				var normalized_delta = delta / half_size
				if bounds.has_point(pos) and (format == Format.SQUARE or normalized_delta.length_squared() <= 1.1):
					var z
					if is_nan(direction):
						z = get_brush_depth(normalized_delta.length(), ease_func)
					else:
						z = get_brush_direction_depth(normalized_delta, ease_func, direction)
					array.append(Vector3(pos.x, pos.y, z))
	return array


static func get_brush_direction_depth(normalized_delta: Vector2, ease_func: FuncRef, direction_: float) -> float:
	var delta_factor = -cos(direction_ - normalized_delta.angle())
	var percent_from_highest = delta_factor * normalized_delta.length() * 0.5 + 0.5
	return get_brush_depth(percent_from_highest, ease_func)

static func get_brush_depth(percent_from_highest: float, ease_func: FuncRef) -> float:
	return 1 - ease_func.call_func(clamp(percent_from_highest, 0, 1))

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
