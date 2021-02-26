extends Object

class_name MapTypes

enum Type {
	ALBEDO_MAP,
	HEIGHT_MAP,
	NORMAL_MAP,
}

const ALBEDO_PROXY_TEXTURE = preload("res://Editor/Project/Albedo_imagetexture.tres")
const HEIGHT_PROXY_TEXTURE = preload("res://Editor/Project/Height_imagetexture.tres")
const NORMAL_PROXY_TEXTURE = preload("res://Editor/Project/Normal_imagetexture.tres")

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

static func map_texture(type: int) -> Texture:
	if type == Type.ALBEDO_MAP:
		return ALBEDO_PROXY_TEXTURE
	elif type == Type.HEIGHT_MAP:
		return HEIGHT_PROXY_TEXTURE
	elif type == Type.NORMAL_MAP:
		return NORMAL_PROXY_TEXTURE
	else:
		assert(false, "Unknown map type %d" % type)
		return null
