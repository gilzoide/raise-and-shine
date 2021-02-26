extends Resource

signal texture_updated(type, texture)

export(Image) var albedo_image: Image
export(Image) var height_image: Image
export(Image) var normal_image: Image
var albedo_texture: ImageTexture = preload("res://Editor/Project/Albedo_imagetexture.tres")
var height_texture: ImageTexture = preload("res://Editor/Project/Height_imagetexture.tres")
var normal_texture: ImageTexture = preload("res://Editor/Project/Normal_imagetexture.tres")

func load_image_dialog(type: int) -> void:
	var method = ""
	if type == MapTypes.Type.ALBEDO_MAP:
		method = "set_albedo_image"
	elif type == MapTypes.Type.HEIGHT_MAP:
		method = "set_height_image"
	elif type == MapTypes.Type.NORMAL_MAP:
		method = "set_normal_image"
	assert(method != "", "Invalid map type %d" % type)
	ImageFileDialog.try_load_image(funcref(self, method))

func set_albedo_image(value: Image) -> void:
	albedo_image = value
	albedo_texture.create_from_image(value)
	emit_signal("texture_updated", MapTypes.Type.ALBEDO_MAP, albedo_texture)

func set_height_image(value: Image) -> void:
	height_image = value
	height_texture.create_from_image(value)
	emit_signal("texture_updated", MapTypes.Type.HEIGHT_MAP, height_texture)

func set_normal_image(value: Image) -> void:
	normal_image = value
	normal_texture.create_from_image(value)
	emit_signal("texture_updated", MapTypes.Type.NORMAL_MAP, normal_texture)
