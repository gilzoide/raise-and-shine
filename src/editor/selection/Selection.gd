# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

enum DragTool {
	BRUSH_RECTANGLE,
	BRUSH_ELLIPSE,
	BRUSH_LINE,
	BRUSH_PENCIL,
	HEIGHT_EDIT,
}

enum SelectionBehaviour {
	UNION,
	DIFFERENCE,
}

const INVALID_POSITION = Vector2(-1, -1)
const SELECTED_PIXEL = SelectionBitMap.TRUE_COLOR
const NOT_SELECTED_PIXEL = SelectionBitMap.FALSE_COLOR

export(float) var drag_height_speed = 0.01
export(ImageTexture) var selection_texture: ImageTexture = preload("res://textures/Selection_imagetexture.tres")
export(ShaderMaterial) var selection_material: ShaderMaterial = preload("res://editor/visualizers/2D/ShowSelection_material.tres")
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")
export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")
export(Resource) var drag_operation = preload("res://editor/operation/DragOperation.tres")
export(DragTool) var active_tool := DragTool.BRUSH_RECTANGLE

var selection_start_behaviour = SelectionBehaviour.UNION
var selection_image: Image = Image.new()
var selection_bitmap: SelectionBitMap = SelectionBitMap.new()
var composed_bitmap: SelectionBitMap = SelectionBitMap.new()
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


func set_drag_operation_started(button_index: int, uv: Vector2) -> void:
	if active_tool == DragTool.BRUSH_RECTANGLE:
		brush.format = SelectionBitMap.Format.RECTANGLE
	elif active_tool == DragTool.BRUSH_ELLIPSE:
		brush.format = SelectionBitMap.Format.ELLIPSE
	elif active_tool == DragTool.BRUSH_LINE:
		brush.format = SelectionBitMap.Format.LINE
	elif active_tool == DragTool.BRUSH_PENCIL:
		brush.format = SelectionBitMap.Format.PENCIL
		brush.set_rect(Rect2(Vector2.ZERO, selection_bitmap.get_size()))
	elif active_tool == DragTool.HEIGHT_EDIT:
		selection_rect = selection_bitmap.get_true_rect()
		return
	
	selection_start_behaviour = SelectionBehaviour.DIFFERENCE if button_index == BUTTON_RIGHT else SelectionBehaviour.UNION
	drag_start_position = uv_to_position(uv)
	drag_selection_moved(drag_start_position)


func set_drag_operation_ended() -> void:
	selection_bitmap.copy_from(composed_bitmap)
	brush.blit_to_image(selection_image)
	if height_changed:
		project.operation_ended()
		height_changed = false


func set_drag_hovering(relative_movement: Vector2, uv: Vector2) -> void:
	if active_tool == DragTool.HEIGHT_EDIT:
		drag_height_moved(relative_movement)
	else:
		drag_selection_moved(uv_to_position(uv))


func drag_height_moved(relative_movement: Vector2) -> void:
	drag_operation.amount = -relative_movement.y * drag_height_speed
	project.apply_operation_to(drag_operation, selection_bitmap, selection_rect)
	height_changed = true


func drag_selection_moved(position: Vector2) -> void:
	if active_tool == DragTool.BRUSH_PENCIL:
		brush.paint_position(position)
	else:
		var delta_pos = position - drag_start_position
		var delta_sign = delta_pos.sign()
		if Input.is_action_pressed("snap_modifier"):
			var abs_delta_pos = delta_pos.abs()
			if abs_delta_pos.y > abs_delta_pos.x:
				position.y = drag_start_position.y + delta_sign.y * abs_delta_pos.x
			elif abs_delta_pos.x > abs_delta_pos.y:
				position.x = drag_start_position.x + delta_sign.x * abs_delta_pos.y
			delta_pos = position - drag_start_position
		var rect := Rect2(drag_start_position, Vector2.ZERO).expand(position)
		if Input.is_action_pressed("selection_center_modifier"):
			rect = rect.expand(drag_start_position - delta_pos)
		rect.size.x = max(1.0, rect.size.x)
		rect.size.y = max(1.0, rect.size.y)
		brush.set_rect(rect, delta_sign.x * delta_sign.y)
	update_selection()


func update_selection() -> void:
	composed_bitmap.copy_from(selection_bitmap)
	if selection_start_behaviour == SelectionBehaviour.DIFFERENCE:
		composed_bitmap.blend_difference(brush.bitmap, brush.rect.position)
	else:
		composed_bitmap.blend_sum(brush.bitmap, brush.rect.position)
	composed_bitmap.blit_to_image(selection_image)
	update_texture()


func uv_to_position(uv: Vector2) -> Vector2:
	return (uv * project.height_image.get_size()).floor()


func clear(bit: bool = false) -> void:
	selection_bitmap.clear(bit)
	composed_bitmap.copy_from(selection_bitmap)
	selection_image.fill(SELECTED_PIXEL if bit else NOT_SELECTED_PIXEL)
	update_texture()


func invert() -> void:
	selection_bitmap.invert()
	composed_bitmap.copy_from(selection_bitmap)
	selection_bitmap.blit_to_image(selection_image)
	update_texture()


func update_texture() -> void:
	selection_texture.set_data(selection_image)
