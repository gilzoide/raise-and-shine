extends Object

class_name HeightNormalConversion

static func new_normalmap_from_heightmap(heightmap: Image):
	var normalmap = Image.new()
	normalmap.copy_from(heightmap)
	normalmap.bumpmap_to_normalmap(min(heightmap.get_width(), heightmap.get_height()))
	return normalmap
