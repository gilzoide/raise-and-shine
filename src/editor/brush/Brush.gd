extends Resource

signal parameter_changed()

enum Format {
	CIRCLE,
	SQUARE,
	RHOMBUS,
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

func set_parameter_changed() -> void:
	emit_signal("parameter_changed")

func get_coordinates(position: Vector2, bounds_size: Vector2) -> PoolVector3Array:
	return get_brush_coordinates(position, bounds_size, size)

func get_affected_rect(position: Vector2, bounds_size: Vector2) -> Rect2:
	return get_brush_rect(position, bounds_size, size + 2)

func get_brush_rect(position: Vector2, bounds_size: Vector2, size_: float) -> Rect2:
	var half_size = int(size_ * 0.5)
	var bounds = Rect2(Vector2.ZERO, bounds_size - Vector2.ONE)
	return Rect2(position - Vector2(half_size, half_size), Vector2(size_, size_)).clip(bounds)

func get_brush_coordinates(position: Vector2, bounds_size: Vector2, size_: float) -> PoolVector3Array:
	var array = PoolVector3Array()
	if size_ <= 1:
		array.append(Vector3(position.x, position.y, 1))
	else:
		var ease_func = easing_func(easing)
		var half_size = size_ * 0.5
		var center_displacement = half_size - floor(half_size)
		var rect = get_brush_rect(position, bounds_size, size_)
		for x in range(rect.position.x, rect.end.x + 1):
			for y in range(rect.position.y, rect.end.y + 1):
				var delta = Vector2(x - position.x - center_displacement, y - position.y - center_displacement)
				var normalized_delta = delta / half_size
				if is_point_in_format(format, delta, half_size):
					var z
					if is_nan(direction):
						z = get_brush_depth(normalized_delta.length(), ease_func)
					else:
						z = get_brush_direction_depth(normalized_delta, ease_func, direction)
					array.append(Vector3(x, y, z))
	return array

static func is_point_in_format(format_: int, delta: Vector2, radius: float) -> bool:
	return format_ == Format.SQUARE \
			or format_ == Format.CIRCLE and Geometry.is_point_in_circle(delta, Vector2.ZERO, radius + 0.25) \
			or format_ == Format.RHOMBUS and abs(delta.x) + abs(delta.y) <= ceil(radius)

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
