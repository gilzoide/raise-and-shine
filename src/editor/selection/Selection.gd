extends Resource

const INVALID_POSITION = Vector2(-1, -1)
const NOT_SELECTED_PIXEL = Color(0, 0, 0, 1)
const SELECTED_PIXEL = Color(1, 0, 0, 1)

export(ImageTexture) var selection_texture: ImageTexture = preload("res://textures/Selection_imagetexture.tres")
export(ShaderMaterial) var selection_material: ShaderMaterial = preload("res://editor/visualizers/2D/ShowSelection_material.tres")
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")
export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")

var selection_image: Image = Image.new()
var last_hover_position: Vector2 = Vector2.ZERO
var current_selected_coordinates: PoolVector3Array
var current_affected_coordinates: PoolVector3Array

func _init() -> void:
	var size = project.height_image.get_size()
	selection_image.create(size.x, size.y, false, Image.FORMAT_L8)
	selection_texture.create_from_image(selection_image, selection_texture.flags)
	selection_material.set_shader_param("selection_texture_pixel_size", Vector2(1.0 / size.x, 1.0 / size.y))
	project.connect("texture_updated", self, "_on_texture_updated")

func _on_texture_updated(type: int, texture: Texture) -> void:
	if type == MapTypes.Type.HEIGHT_MAP:
		var new_size = texture.get_size()
		selection_image.resize(new_size.x, new_size.y, Image.INTERPOLATE_NEAREST)
		selection_texture.create_from_image(selection_image, selection_texture.flags)
		selection_material.set_shader_param("selection_texture_pixel_size", Vector2(1.0 / new_size.x, 1.0 / new_size.y))

func empty() -> bool:
	return current_selected_coordinates.empty()

func set_mouse_hovering_uv(uv: Vector2) -> void:
	uv.x = clamp(uv.x, 0, 1)
	uv.y = clamp(uv.y, 0, 1)
	var position = (uv * project.height_image.get_size()).floor()
	set_mouse_hovering(position)

func set_mouse_hovering(position: Vector2) -> void:
	selection_image.lock()
	clear_last_hover()
	current_selected_coordinates = brush.get_coordinates(position, selection_image.get_size())
	current_affected_coordinates = brush.get_affected_coordinates(position, selection_image.get_size())
	for c in current_selected_coordinates:
		selection_image.set_pixel(c.x, c.y, SELECTED_PIXEL)
	selection_image.unlock()
	update_texture()

func mouse_exited_hovering() -> void:
	selection_image.lock()
	clear_last_hover()
	selection_image.unlock()
	update_texture()

func clear_last_hover() -> void:
	for c in current_selected_coordinates:
		selection_image.set_pixel(c.x, c.y, NOT_SELECTED_PIXEL)
	current_selected_coordinates.resize(0)

func update_texture() -> void:
	selection_texture.set_data(selection_image)
