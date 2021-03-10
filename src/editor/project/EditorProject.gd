extends Resource

signal texture_updated(type, texture)
signal height_changed(data, rect)

export(Image) var albedo_image: Image = MapTypes.ALBEDO_IMAGE
export(Image) var height_image: Image = MapTypes.HEIGHT_IMAGE
export(Image) var normal_image: Image = MapTypes.NORMAL_IMAGE
export(ImageTexture) var albedo_texture: ImageTexture = MapTypes.ALBEDO_TEXTURE
export(ImageTexture) var height_texture: ImageTexture = MapTypes.HEIGHT_TEXTURE
export(ImageTexture) var normal_texture: ImageTexture = MapTypes.NORMAL_TEXTURE
export(Resource) var history = preload("res://editor/undo/UndoHistory.tres")

var height_data: HeightMapData = HeightMapData.new()

func _init() -> void:
	._init()
	height_image.create(64, 64, false, HeightMapData.HEIGHT_IMAGE_FORMAT)
	set_height_image(height_image)
	history.set_heightmapdata(height_data)
	history.connect("revision_changed", self, "_on_revision_changed")

func _on_revision_changed(data: HeightMapData) -> void:
	height_data = data
	height_data.fill_image(height_image)
	height_texture.create_from_image(height_image, height_texture.flags)
	height_data.fill_normalmap(normal_image)
	normal_texture.create_from_image(normal_image, normal_texture.flags)

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
	albedo_texture.create_from_image(albedo_image, albedo_texture.flags)
	emit_signal("texture_updated", MapTypes.Type.ALBEDO_MAP, albedo_texture)

func set_height_image(value: Image) -> void:
	height_image.copy_from(value)
	height_image.convert(HeightMapData.HEIGHT_IMAGE_FORMAT)
	height_data.copy_from_image(height_image)
	height_texture.create_from_image(height_image, height_texture.flags)
	emit_signal("texture_updated", MapTypes.Type.HEIGHT_MAP, height_texture)
	set_normal_image(height_data.create_normalmap())

func set_normal_image(value: Image) -> void:
	normal_image.copy_from(value)
	normal_texture.create_from_image(normal_image, normal_texture.flags)
	emit_signal("texture_updated", MapTypes.Type.NORMAL_MAP, normal_texture)

func apply_operation_to(operation, bitmap: BitMap, rect: Rect2) -> void:
	operation.apply(height_data, bitmap, rect)
	height_data.fill_image(height_image)
	height_texture.set_data(height_image)
	var changed_rect = rect.grow(1).clip(Rect2(Vector2.ZERO, height_data.size))
	height_data.fill_normalmap(normal_image, changed_rect)
	normal_texture.set_data(normal_image)
	emit_signal("height_changed", height_data, changed_rect)

func operation_ended() -> void:
	history.push_heightmapdata(height_data)
