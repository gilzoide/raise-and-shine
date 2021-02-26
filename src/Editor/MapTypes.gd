extends Object

class_name MapTypes

enum Type {
	ALBEDO_MAP,
	HEIGHT_MAP,
	NORMAL_MAP,
}

static func map_name(type: int) -> String:
	if type == Type.ALBEDO_MAP:
		return "Albedo"
	elif type == Type.HEIGHT_MAP:
		return "Height"
	elif type == Type.NORMAL_MAP:
		return "Normal"
	else:
		assert(false, "Unknown map type %d" % type)
		return ""
