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


export(float) var drag_height_speed = 0.01
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")
export(Resource) var drag_operation = preload("res://editor/operation/DragOperation.tres")
export(DragTool) var active_tool := DragTool.BRUSH_RECTANGLE

var drag_start_position: Vector2
var height_changed = false


func set_active_tool(new_tool: int) -> void:
	active_tool = new_tool
	if active_tool == DragTool.HEIGHT_EDIT:
		drag_operation.cache_target_from_selection(SelectionDrawer.snapshot_image)


func set_drag_operation_started(button_index: int, uv: Vector2) -> void:
	if active_tool == DragTool.HEIGHT_EDIT:
		return
	
	var is_union = button_index != BUTTON_RIGHT
	if active_tool == DragTool.BRUSH_RECTANGLE:
		SelectionDrawer.set_format(SelectionCanvasItem.Format.RECTANGLE, is_union)
	elif active_tool == DragTool.BRUSH_ELLIPSE:
		SelectionDrawer.set_format(SelectionCanvasItem.Format.ELLIPSE, is_union)
	elif active_tool == DragTool.BRUSH_LINE:
		SelectionDrawer.set_format(SelectionCanvasItem.Format.LINE, is_union)
	elif active_tool == DragTool.BRUSH_PENCIL:
		SelectionDrawer.set_format(SelectionCanvasItem.Format.PENCIL, is_union)
	
	drag_start_position = uv_to_position(uv)
	drag_selection_moved(drag_start_position)


func set_drag_operation_ended() -> void:
	update_selection_bitmap()
	if height_changed:
		project.height_operation_ended(drag_operation)
		height_changed = false


func set_drag_hovering(relative_movement: Vector2, uv: Vector2) -> void:
	if active_tool == DragTool.HEIGHT_EDIT:
		drag_height_moved(relative_movement)
	else:
		drag_selection_moved(uv_to_position(uv))


func drag_height_moved(relative_movement: Vector2) -> void:
	drag_operation.amount = -relative_movement.y * drag_height_speed
	project.apply_operation_to(drag_operation)
	height_changed = true


func drag_selection_moved(position: Vector2) -> void:
	if active_tool == DragTool.BRUSH_PENCIL:
		SelectionDrawer.paint_position(position)
	else:
		var pivot_point = drag_start_position
		# snap rect to hovered pixel, as `uv_to_position` always floors position
		if position.x > drag_start_position.x:
			position.x += 1
		else:
			pivot_point.x += 1
		if position.y > drag_start_position.y:
			position.y += 1
		else:
			pivot_point.y += 1
		
		var delta_pos = position - pivot_point
		var delta_sign = delta_pos.sign()
		if Input.is_action_pressed("snap_modifier"):
			var abs_delta_pos = delta_pos.abs()
			if abs_delta_pos.y > abs_delta_pos.x:
				position.y = pivot_point.y + delta_sign.y * abs_delta_pos.x
			elif abs_delta_pos.x > abs_delta_pos.y:
				position.x = pivot_point.x + delta_sign.x * abs_delta_pos.y
			delta_pos = position - pivot_point
		var rect := Rect2(pivot_point, Vector2.ZERO).expand(position)
		if Input.is_action_pressed("selection_center_modifier"):
			rect = rect.expand(pivot_point - delta_pos)
		rect.size.x = max(1.0, rect.size.x)
		rect.size.y = max(1.0, rect.size.y)
		SelectionDrawer.update_selection_rect(rect, delta_sign.x * delta_sign.y)


func get_cursor_for_active_tool() -> int:
	if active_tool == DragTool.HEIGHT_EDIT:
		return Control.CURSOR_VSIZE
	else:
		return Control.CURSOR_CROSS


func uv_to_position(uv: Vector2) -> Vector2:
	return (uv * SelectionDrawer.size).floor()


func clear(bit: bool = false) -> void:
	SelectionDrawer.clear(bit)
	update_selection_bitmap()


func invert() -> void:
	SelectionDrawer.invert()
	update_selection_bitmap()


func update_selection_bitmap() -> void:
	yield(VisualServer, "frame_post_draw")
	SelectionDrawer.take_snapshot()
	if active_tool == DragTool.HEIGHT_EDIT:
		drag_operation.cache_target_from_selection(SelectionDrawer.snapshot_image)
