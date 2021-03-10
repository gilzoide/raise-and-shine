extends Object

class_name HeightMapProcessing

static func new_normalmap_from_heightmap(heightmap: Image) -> Image:
	var normalmap = Image.new()
	normalmap.copy_from(heightmap)
	normalmap.bumpmap_to_normalmap(min(heightmap.get_width(), heightmap.get_height()))
	return normalmap

static func recalculate_normals(heightmap: HeightMapData, normalmap: Image, rect: Rect2) -> void:
	var bounds = heightmap.size
	var bump_scale = min(bounds.x, bounds.y)
	normalmap.lock()
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var here = heightmap.get_value(x, y)
			var right = heightmap.get_value(x + 1, y) if x + 1 < bounds.x else here
			var below = heightmap.get_value(x, y + 1) if y + 1 < bounds.y else here
			var up = Vector3(0, 1, (here - below) * bump_scale)
			var across = Vector3(1, 0, (right - here) * bump_scale)
			var normal = across.cross(up).normalized()
			var normal_rgb = normal * 0.5 + Vector3(0.5, 0.5, 0.5)
			normalmap.set_pixel(x, y, Color(normal_rgb.x, normal_rgb.y, normal_rgb.z, 1))
	normalmap.unlock()
