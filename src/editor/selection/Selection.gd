extends Resource

signal selection_changed()

const INVALID_POSITION = Vector2(-1, -1)
const NOT_SELECTED_PIXEL = Color.black
const SELECTED_PIXEL = Color.white
const selection_texture: ImageTexture = preload("res://textures/Selection_imagetexture.tres")

export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")

var selection_image: Image = Image.new()
var last_hover_position: Vector2 = Vector2.ZERO

func _init() -> void:
	var size = project.height_image.get_size()
	selection_image.create(size.x, size.y, false, Image.FORMAT_L8)
	selection_texture.create_from_image(selection_image, selection_texture.flags)
	project.connect("texture_updated", self, "_on_texture_updated")

func _on_texture_updated(type: int, texture: Texture) -> void:
	if type == MapTypes.Type.HEIGHT_MAP:
		var new_size = texture.get_size()
		selection_image.resize(new_size.x, new_size.y, Image.INTERPOLATE_NEAREST)

func set_mouse_hovering(position: Vector2) -> void:
	if not position.is_equal_approx(last_hover_position):
		selection_image.lock()
		clear_last_hover()
		selection_image.set_pixelv(position, SELECTED_PIXEL)
		selection_image.unlock()
		update_texture()
		last_hover_position = position

func mouse_exited_hovering() -> void:
	selection_image.lock()
	clear_last_hover()
	selection_image.unlock()
	update_texture()
	last_hover_position = INVALID_POSITION

func clear_last_hover() -> void:
	if not last_hover_position.is_equal_approx(INVALID_POSITION):
		selection_image.set_pixelv(last_hover_position, NOT_SELECTED_PIXEL)

func update_texture() -> void:
	selection_texture.set_data(selection_image)
