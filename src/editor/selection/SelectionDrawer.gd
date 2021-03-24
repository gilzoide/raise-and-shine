# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Viewport

signal snapshot_updated()

const PENCIL_IMAGE_FORMAT = Image.FORMAT_L8
const PENCIL_TEXTURE_FLAGS = 0

export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")
export(ShaderMaterial) var selection_material = preload("res://editor/visualizers/2D/ShowSelection_material.tres")
export(ShaderMaterial) var plane_material = preload("res://editor/visualizers/3D/Plane_material.tres")

var snapshot_image := Image.new()
var snapshot_texture := ImageTexture.new()

onready var background = $Background
onready var current_selection = $CurrentSelection
onready var active_brush = $ActiveBrush


func _ready() -> void:
	background.color = SelectionCanvasItem.UNSELECTED_COLOR
	update_with_size(project.height_texture.get_size())
	var texture = get_texture()
	texture.flags = 0
	snapshot_image = texture.get_data()
	snapshot_texture.create_from_image(snapshot_image, 0)
	current_selection.texture = snapshot_texture
	plane_material.set_shader_param("selection_map", texture)
	selection_material.set_shader_param("selection_map", texture)
	project.connect("height_texture_changed", self, "_on_texture_changed")


func update_with_size(new_size: Vector2) -> void:
	size = new_size
	background.rect_size = size
	current_selection.rect_size = size
	selection_material.set_shader_param("selection_texture_pixel_size", Vector2(1.0 / size.x, 1.0 / size.y))


func _on_texture_changed(texture: Texture, _empty_data: bool = false) -> void:
	var new_size = texture.get_size()
	if size != new_size:
		update_with_size(new_size)
	var format = snapshot_image.get_format()
	snapshot_image.create(int(size.x), int(size.y), false, format)
	snapshot_texture.create_from_image(snapshot_image, 0)
	active_brush.rect_size = size if active_brush.format == SelectionCanvasItem.Format.PENCIL else Vector2.ZERO
	redraw()
	emit_signal("snapshot_updated")


func set_format(format: int, is_union: bool) -> void:
	active_brush.format = format
	active_brush.set_selection_union(is_union)
	if format == SelectionCanvasItem.Format.PENCIL:
		active_brush.rect_position = Vector2.ZERO
		active_brush.rect_size = size


func set_selection(selection: Image) -> void:
	var new_size = selection.get_size()
	if size != new_size:
		update_with_size(new_size)
	var format = snapshot_image.get_format()
	snapshot_image.copy_from(selection)
	snapshot_image.convert(format)
	snapshot_texture.create_from_image(snapshot_image, snapshot_texture.flags)
	active_brush.rect_size = size if active_brush.format == SelectionCanvasItem.Format.PENCIL else Vector2.ZERO
	redraw()
	emit_signal("snapshot_updated")


func update_selection_rect(rect: Rect2, line_direction: float = 1.0) -> void:
	active_brush.rect_position = rect.position
	active_brush.rect_size = rect.size
	active_brush.line_direction = line_direction
	redraw()


func paint_position(position: Vector2) -> void:
	if Rect2(Vector2.ZERO, size).has_point(position):
		active_brush.paint_position(position)
		redraw()


func redraw() -> void:
	active_brush.update()
	render_target_update_mode = Viewport.UPDATE_ONCE


func clear(bit: bool = false) -> void:
	active_brush.format = SelectionCanvasItem.Format.RECTANGLE
	active_brush.set_selection_union(bit)
	update_selection_rect(Rect2(Vector2.ZERO, size))


func invert() -> void:
	background.color = SelectionCanvasItem.SELECTED_COLOR
	current_selection.set_selection_union(false)
	active_brush.rect_size = Vector2.ZERO
	redraw()
	yield(VisualServer, "frame_post_draw")
	background.color = SelectionCanvasItem.UNSELECTED_COLOR
	current_selection.set_selection_union(true)


func take_snapshot() -> void:
	yield(VisualServer, "frame_post_draw")
	snapshot_image = get_texture().get_data()
	snapshot_texture.set_data(snapshot_image)
	active_brush.clear_positions()
	emit_signal("snapshot_updated")
