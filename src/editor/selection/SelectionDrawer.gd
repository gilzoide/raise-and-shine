# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Viewport

export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")
export(ShaderMaterial) var selection_material = preload("res://editor/visualizers/2D/ShowSelection_material.tres")
export(ShaderMaterial) var plane_material = preload("res://editor/visualizers/3D/Plane_material.tres")

onready var current_selection = $CurrentSelection
onready var active_brush = $ActiveBrush

var snapshot_image := Image.new()
var snapshot_texture := ImageTexture.new()
var pencil_image := Image.new()
var pencil_texture := ImageTexture.new()


func _ready() -> void:
	_on_texture_changed(project.height_texture)
	var _err = project.connect("height_texture_changed", self, "_on_texture_changed")
	var texture = get_texture()
	texture.flags = 0
	selection_material.set_shader_param("selection_map", texture)
	plane_material.set_shader_param("selection_map", texture)
	current_selection.texture = snapshot_texture


func _on_texture_changed(texture: Texture, _empty_data: bool = false) -> void:
	size = texture.get_size()
	selection_material.set_shader_param("selection_texture_pixel_size", Vector2(1.0 / size.x, 1.0 / size.y))
	current_selection.rect_position = Vector2.ZERO
	current_selection.rect_size = size
	snapshot_image = get_texture().get_data()
	snapshot_texture.create_from_image(snapshot_image, 0)
	pencil_image.create(int(size.x), int(size.y), false, Image.FORMAT_L8)
	pencil_texture.create_from_image(pencil_image, 0)


func set_format(format: int, is_union: bool) -> void:
	active_brush.format = format
	active_brush.set_selection_union(is_union)
	if format == SelectionCanvasItem.Format.PENCIL:
		active_brush.texture = pencil_texture
		active_brush.rect_position = Vector2.ZERO
		active_brush.rect_size = size


func update_selection_rect(rect: Rect2, line_direction: float = 1.0) -> void:
	active_brush.rect_position = rect.position
	active_brush.rect_size = rect.size
	active_brush.line_direction = line_direction
	redraw()


func paint_position(position: Vector2) -> void:
	if Rect2(Vector2.ZERO, size).has_point(position):
		pencil_image.lock()
		pencil_image.set_pixelv(position, SelectionCanvasItem.SELECTED_COLOR)
		pencil_image.unlock()
		pencil_texture.set_data(pencil_image)
		redraw()


func redraw() -> void:
	active_brush.update()
	render_target_update_mode = Viewport.UPDATE_ONCE


func clear(bit: bool = false) -> void:
	active_brush.format = SelectionCanvasItem.Format.RECTANGLE
	active_brush.set_selection_union(bit)
	update_selection_rect(Rect2(Vector2.ZERO, size))


func invert() -> void:
	current_selection.format = SelectionCanvasItem.Format.RECTANGLE
	current_selection.update()
	active_brush.format = SelectionCanvasItem.Format.TEXTURE
	active_brush.texture = snapshot_texture
	active_brush.set_selection_union(false)
	update_selection_rect(Rect2(Vector2.ZERO, size))
	yield(VisualServer, "frame_post_draw")
	current_selection.format = SelectionCanvasItem.Format.TEXTURE
	current_selection.update()


func take_snapshot() -> Image:
	snapshot_image = get_texture().get_data()
	snapshot_texture.set_data(snapshot_image)
	return snapshot_image
