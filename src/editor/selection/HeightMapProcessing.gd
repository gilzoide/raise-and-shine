extends Object

class_name HeightMapProcessing

static func new_normalmap_from_heightmap(heightmap: Image):
	var normalmap = Image.new()
	normalmap.copy_from(heightmap)
	normalmap.bumpmap_to_normalmap(min(heightmap.get_width(), heightmap.get_height()))
	return normalmap

static func recalculate_normals(heightmap: Image, normalmap: Image, coordinates: PoolVector3Array) -> void:
	heightmap.lock()
	normalmap.lock()
	var bounds = heightmap.get_size()
	var bump_scale = min(heightmap.get_width(), heightmap.get_height())
	for c in coordinates:
		var v = Vector2(c.x, c.y)
		var here = heightmap.get_pixelv(v).r
		var right = heightmap.get_pixelv(v + Vector2(1, 0)).r if v.x + 1 < bounds.x else here
		var below = heightmap.get_pixelv(v + Vector2(0, 1)).r if v.y + 1 < bounds.y else here
		var up = Vector3(0, 1, (here - below) * bump_scale)
		var across = Vector3(1, 0, (right - here) * bump_scale)
		var normal = across.cross(up).normalized()
		var normal_rgb = Color(normal.x + 0.5, normal.y + 0.5, normal.z + 0.5, 1)
		normalmap.set_pixelv(v, normal_rgb)
	normalmap.unlock()
	heightmap.unlock()
