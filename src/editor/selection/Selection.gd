extends Resource

enum DragOperation {
	BRUSH_RECTANGLE,
	BRUSH_ELLIPSE,
}

const INVALID_POSITION = Vector2(-1, -1)
const NOT_SELECTED_PIXEL = Color(0, 0, 0, 1)
const SELECTED_PIXEL = Color(1, 0, 0, 1)

export(ImageTexture) var selection_texture: ImageTexture = preload("res://textures/Selection_imagetexture.tres")
export(ShaderMaterial) var selection_material: ShaderMaterial = preload("res://editor/visualizers/2D/ShowSelection_material.tres")
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")
export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")
export(DragOperation) var drag_operation = DragOperation.BRUSH_RECTANGLE

var selection_image: Image = Image.new()
var selection_bitmap: BitMapPlus = BitMapPlus.new()
var selection_rect: Rect2 = Rect2()
var drag_start_position: Vector2

func _init() -> void:
	update_with_size(project.height_image)
	project.connect("texture_updated", self, "_on_texture_updated")

func _on_texture_updated(type: int, texture: Texture) -> void:
	if type == MapTypes.Type.HEIGHT_MAP:
		update_with_size(texture)

func update_with_size(image_or_texture) -> void:
	var size: Vector2 = image_or_texture.get_size()
	selection_bitmap.create(size)
	selection_image = selection_bitmap.create_image()
	selection_texture.create_from_image(selection_image, selection_texture.flags)
	selection_material.set_shader_param("selection_texture_pixel_size", Vector2(1.0 / size.x, 1.0 / size.y))

func empty() -> bool:
	return selection_rect.has_no_area()

func set_drag_operation_started(uv: Vector2) -> void:
	if drag_operation == DragOperation.BRUSH_RECTANGLE:
		brush.format = BitMapPlus.Format.RECTANGLE
	elif drag_operation == DragOperation.BRUSH_ELLIPSE:
		brush.format = BitMapPlus.Format.ELLIPSE
	drag_start_position = uv_to_position(uv)

func set_drag_operation_ended() -> void:
	brush.blit_to_image(selection_image)

func set_drag_hovering_uv(uv: Vector2) -> void:
	var position = uv_to_position(uv)
	var rect = Rect2(drag_start_position, Vector2.ONE).expand(position)
	brush.set_rect(rect)
	var ored_bitmap = BitMapPlus.new()
	ored_bitmap.copy_from(selection_bitmap)
	ored_bitmap.blend_or(brush.bitmap, rect.position)
	ored_bitmap.blit_to_image(selection_image)
	update_texture()

func uv_to_position(uv: Vector2) -> Vector2:
	uv.x = clamp(uv.x, 0, 1)
	uv.y = clamp(uv.y, 0, 1)
	return (uv * project.height_image.get_size()).floor()

func mouse_exited_hovering() -> void:
	pass

func update_texture() -> void:
	selection_texture.set_data(selection_image)
