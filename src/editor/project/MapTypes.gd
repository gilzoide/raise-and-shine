extends Object

class_name MapTypes

enum Type {
	ALBEDO_MAP,
	HEIGHT_MAP,
	NORMAL_MAP,
}

const ALBEDO_IMAGE = preload("res://textures/P1_2_Hair.png")
const HEIGHT_IMAGE = preload("res://textures/P1_2_Hair_height.png")
const NORMAL_IMAGE = preload("res://textures/P1_2_Hair_normal.png")

const ALBEDO_TEXTURE = preload("res://textures/Albedo_imagetexture.tres")
const HEIGHT_TEXTURE = preload("res://textures/Height_imagetexture.tres")
const NORMAL_TEXTURE = preload("res://textures/Normal_imagetexture.tres")

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
		return ALBEDO_TEXTURE
	elif type == Type.HEIGHT_MAP:
		return HEIGHT_TEXTURE
	elif type == Type.NORMAL_MAP:
		return NORMAL_TEXTURE
	else:
		assert(false, "Unknown map type %d" % type)
		return null
