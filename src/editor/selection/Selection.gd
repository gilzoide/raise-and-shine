extends Resource

enum DragTool {
	BRUSH_RECTANGLE,
	BRUSH_ELLIPSE,
	HEIGHT_EDIT,
}

enum SelectionBehaviour {
	REPLACE,
	UNION,
	DIFFERENCE,
}

const INVALID_POSITION = Vector2(-1, -1)
const SELECTED_PIXEL = BitMapPlus.TRUE_COLOR
const NOT_SELECTED_PIXEL = BitMapPlus.FALSE_COLOR

export(float) var drag_height_speed = 0.01
export(ImageTexture) var selection_texture: ImageTexture = preload("res://textures/Selection_imagetexture.tres")
export(ShaderMaterial) var selection_material: ShaderMaterial = preload("res://editor/visualizers/2D/ShowSelection_material.tres")
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")
export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")
export(Resource) var drag_operation = preload("res://editor/operation/DragOperation.tres")
export(DragTool) var active_tool = DragTool.BRUSH_RECTANGLE

var selection_start_behaviour
var selection_image: Image = Image.new()
var selection_bitmap: BitMapPlus = BitMapPlus.new()
var composed_bitmap: BitMapPlus = BitMapPlus.new()
var selection_rect: Rect2 = Rect2()
var drag_start_position: Vector2
var height_changed = false

func _init() -> void:
	update_with_size(project.height_image)
	composed_bitmap.create(project.height_image.get_size())
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
	if active_tool == DragTool.BRUSH_RECTANGLE:
		brush.format = BitMapPlus.Format.RECTANGLE
	elif active_tool == DragTool.BRUSH_ELLIPSE:
		brush.format = BitMapPlus.Format.ELLIPSE
	elif active_tool == DragTool.HEIGHT_EDIT:
		selection_rect = selection_bitmap.get_true_rect()
		return
	
	selection_start_behaviour = current_selection_behaviour()
	if selection_start_behaviour == SelectionBehaviour.REPLACE:
		selection_bitmap.clear()
	
	drag_start_position = uv_to_position(uv)

func set_drag_operation_ended() -> void:
	selection_bitmap.copy_from(composed_bitmap)
	brush.blit_to_image(selection_image)
	if height_changed:
		project.operation_ended()
		height_changed = false

func set_drag_hovering(event: InputEventMouseMotion, uv: Vector2) -> void:
	if active_tool == DragTool.HEIGHT_EDIT:
		drag_height_moved(event)
	else:
		drag_selection_moved(uv)

func drag_height_moved(event: InputEventMouseMotion) -> void:
	drag_operation.amount = -event.relative.y * drag_height_speed
	project.apply_operation_to(drag_operation, selection_bitmap, selection_rect)
	height_changed = true

func drag_selection_moved(uv: Vector2) -> void:
	var position = uv_to_position(uv)
	if Input.is_action_pressed("snap_modifier"):
		var delta_pos: Vector2 = position - drag_start_position
		var abs_delta_pos = delta_pos.abs()
		if abs_delta_pos.y > abs_delta_pos.x:
			position.y -= sign(delta_pos.y) * (abs_delta_pos.y - abs_delta_pos.x)
		elif abs_delta_pos.x > abs_delta_pos.y:
			position.x -= sign(delta_pos.x) * (abs_delta_pos.x - abs_delta_pos.y)
	var rect: Rect2 = Rect2(drag_start_position, Vector2.ONE).expand(position)
	if Input.is_action_pressed("selection_center_modifier"):
		var delta_pos = position - drag_start_position
		rect = rect.expand(drag_start_position - delta_pos)
	brush.set_rect(rect)
	composed_bitmap.copy_from(selection_bitmap)
	if selection_start_behaviour == SelectionBehaviour.DIFFERENCE:
		composed_bitmap.blend_difference(brush.bitmap, rect.position)
	else:
		composed_bitmap.blend_sum(brush.bitmap, rect.position)
	composed_bitmap.blit_to_image(selection_image)
	update_texture()

func uv_to_position(uv: Vector2) -> Vector2:
#	uv.x = clamp(uv.x, 0, 1)
#	uv.y = clamp(uv.y, 0, 1)
	return (uv * project.height_image.get_size()).floor()

func mouse_exited_hovering() -> void:
	pass

func clear(bit: bool = false) -> void:
	selection_bitmap.clear(bit)
	selection_image.fill(SELECTED_PIXEL if bit else NOT_SELECTED_PIXEL)
	selection_rect = Rect2(Vector2.ZERO, selection_bitmap.get_size()) if bit else Rect2()
	update_texture()

func invert() -> void:
	selection_bitmap.invert()
	selection_bitmap.blit_to_image(selection_image)
	update_texture()

func update_texture() -> void:
	selection_texture.set_data(selection_image)

static func current_selection_behaviour() -> int:
	if Input.is_action_pressed("selection_difference_modifier"):
		return SelectionBehaviour.DIFFERENCE
	elif Input.is_action_pressed("selection_union_modifier"):
		return SelectionBehaviour.UNION
	else:
		return SelectionBehaviour.REPLACE
