extends Resource

signal texture_updated(type, texture)

var albedo_image: Image = MapTypes.ALBEDO_IMAGE
var height_image: Image = MapTypes.HEIGHT_IMAGE
var normal_image: Image = MapTypes.NORMAL_IMAGE
var albedo_texture: ImageTexture = MapTypes.ALBEDO_TEXTURE
var height_texture: ImageTexture = MapTypes.HEIGHT_TEXTURE
var normal_texture: ImageTexture = MapTypes.NORMAL_TEXTURE

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

func save_image_dialog(type: int) -> void:
	var image: Image = null
	if type == MapTypes.Type.ALBEDO_MAP:
		image = albedo_image
	elif type == MapTypes.Type.HEIGHT_MAP:
		image = height_image
	elif type == MapTypes.Type.NORMAL_MAP:
		image = normal_image
	assert(image != null, "Invalid map type %d" % type)
	ImageFileDialog.try_save_image(image)

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
