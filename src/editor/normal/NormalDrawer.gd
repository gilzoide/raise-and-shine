# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Viewport

export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")
export(ShaderMaterial) var height_to_normal_material = preload("res://editor/normal/HeightToNormal_material.tres")

onready var height_map_rect = $HeightMapRect
onready var current_normal = $CurrentNormal
onready var is_gles3 = OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES3


func _ready() -> void:
	get_texture().flags = Texture.FLAG_FILTER
	height_map_rect.texture = HeightDrawer.get_texture()
	height_map_rect.subrect = Rect2(Vector2.ZERO, size)
	_on_height_texture_changed(project.height_texture)
	project.connect("height_texture_changed", self, "_on_height_texture_changed")
	project.connect("normal_texture_changed", self, "_on_normal_texture_changed")
	var _err = HeightDrawer.connect("brush_drawn", self, "update_height_in_rect")
	_err = HeightDrawer.connect("cleared", self, "_on_height_drawer_cleared")


func update_height_in_rect(rect: Rect2) -> void:
	height_map_rect.subrect = rect.grow(1).clip(Rect2(Vector2.ZERO, size))
	height_map_rect.update()
	render_target_update_mode = Viewport.UPDATE_ONCE


func _on_normal_texture_changed(texture: Texture) -> void:
	current_normal.texture = texture
	current_normal.visible = true
	current_normal.update()
	render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
	render_target_update_mode = Viewport.UPDATE_ONCE
	yield(VisualServer, "frame_post_draw")
	current_normal.visible = false


func take_snapshot() -> void:
	project.normal_image = get_texture().get_data()
	project.normal_image.convert(HeightMapData.NORMAL_IMAGE_FORMAT)
	project.normal_texture.create_from_image(project.normal_image, project.normal_texture.flags)


func _on_height_texture_changed(texture: Texture, _empty_data: bool = false) -> void:
	var new_size = texture.get_size()
	if not new_size.is_equal_approx(size):
		size = new_size
		current_normal.rect_size = new_size
		height_map_rect.rect_size = new_size


func _on_height_drawer_cleared() -> void:
	update_height_in_rect(Rect2(Vector2.ZERO, size))
