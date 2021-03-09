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

export(Operation) var type = Operation.INCREASE_BY
export(float) var amount = 0.1
export(Easing) var easing = Easing.FLAT
export(float) var direction = RADIAL_DIRECTION

func apply(heightmap: HeightMapData, coordinates: PoolVector3Array) -> void:
	apply_to(heightmap, coordinates, type, amount)

static func is_radial_direction(value: float) -> bool:
	return is_nan(value)

static func apply_to(heightmap: HeightMapData, coordinates: PoolVector3Array, type_: int, value: float) -> void:
	if type_ == Operation.INCREASE_BY:
		offset_by(heightmap, coordinates, value)
	elif type_ == Operation.DECREASE_BY:
		offset_by(heightmap, coordinates, -value)
	elif type_ == Operation.SET_VALUE:
		set_height(heightmap, coordinates, value)

static func offset_by(heightmap: HeightMapData, coordinates: PoolVector3Array, value: float) -> void:
	for c in coordinates:
		var height = heightmap.get_value(c.x, c.y)
		height = clamp(height + value * c.z, 0, 1)
		heightmap.set_value(c.x, c.y, height)

static func set_height(heightmap: HeightMapData, coordinates: PoolVector3Array, value: float) -> void:
	for c in coordinates:
		var height = value * c.z
		heightmap.set_value(c.x, c.y, height)

static func get_direction_depth(normalized_delta: Vector2, ease_func: FuncRef, direction_: float) -> float:
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
