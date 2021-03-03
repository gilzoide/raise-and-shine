extends Resource

enum Operation {
	INCREASE_BY,
	DECREASE_BY,
	SET_VALUE,
}

export(Operation) var type = Operation.INCREASE_BY
export(float) var amount = 0.1

func apply(heightmap: Image, coordinates: PoolVector3Array) -> void:
	apply_to(heightmap, coordinates, type, amount)

static func apply_to(heightmap: Image, coordinates: PoolVector3Array, type_: int, value: float) -> void:
	if type_ == Operation.INCREASE_BY:
		offset_by(heightmap, coordinates, value)
	elif type_ == Operation.DECREASE_BY:
		offset_by(heightmap, coordinates, -value)
	elif type_ == Operation.SET_VALUE:
		set_height(heightmap, coordinates, value)

static func offset_by(heightmap: Image, coordinates: PoolVector3Array, value: float) -> void:
	heightmap.lock()
	for c in coordinates:
		var height = heightmap.get_pixel(c.x, c.y).r
		height = clamp(height + value * c.z, 0, 1)
		heightmap.set_pixel(c.x, c.y, Color(height, height, height, 1))
	heightmap.unlock()

static func set_height(heightmap: Image, coordinates: PoolVector3Array, value: float) -> void:
	heightmap.lock()
	for c in coordinates:
		var height = value * c.z
		heightmap.set_pixel(c.x, c.y, Color(height, height, height, 1))
	heightmap.unlock()

