# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Spatial

signal drag_started(button_index, uv)
signal drag_moved(relative_motion, uv)
signal drag_ended()

const project = preload("res://editor/project/ActiveEditorProject.tres")
const history = preload("res://editor/undo/UndoHistory.tres")
const plane_material = preload("res://editor/visualizers/3D/Plane_material.tres")
const plane_mesh = preload("res://editor/visualizers/3D/PlaneMesh.tres")
const operation = preload("res://editor/operation/DragOperation.tres")
const selection = preload("res://editor/selection/ActiveSelection.tres")

export(float) var plate_angular_speed = 0.01
export(float) var plane_subdivide_scale = 1

var alpha_enabled: bool setget set_alpha_enabled, get_alpha_enabled
var lights_enabled: bool setget set_lights_enabled, get_lights_enabled
var normal_vectors_enabled: bool setget set_normal_vectors_enabled, get_normal_vectors_enabled
onready var plate = $Plate
onready var border = $Plate/Border
onready var heightmapshape_collision = $Plate/HeightMapShape
onready var lights = $Lights
onready var ambient_light = $WorldEnvironment
onready var normal_vectors = $Plate/Model/NormalVectorsMultiMeshInstance
onready var initial_plane_size := plane_mesh.size
onready var plane_size := initial_plane_size


func _ready() -> void:
	plane_material.set_shader_param("normal_map", NormalDrawer.get_texture())
	update_plane_dimensions()
	var _err = project.connect("height_texture_changed", self, "_on_texture_updated")
	_err = project.connect("operation_ended", self, "_on_operation_ended")


func update_plane_dimensions() -> void:
	var height_map = project.height_image
	var albedo_size = project.albedo_image.get_size()
	if albedo_size.x > albedo_size.y:
		plane_size.x = initial_plane_size.x
		plane_size.y = initial_plane_size.y / albedo_size.aspect()
	else:
		plane_size.x = initial_plane_size.x * albedo_size.aspect()
		plane_size.y = initial_plane_size.y
	var size = height_map.get_size()
	plane_mesh.subdivide_width = size.x * plane_subdivide_scale
	plane_mesh.subdivide_depth = size.y * plane_subdivide_scale
	plane_mesh.size = plane_size
	normal_vectors.plane_size = plane_size
	border.setup_with_plane_size(plane_size)
	var plane_heightmapshape = heightmapshape_collision.shape
	plane_heightmapshape.map_width = max(size.x, 2)
	plane_heightmapshape.map_depth = max(size.y, 2)
	heightmapshape_collision.scale.x = plane_size.x / max(size.x - 1, 1)
	heightmapshape_collision.scale.z = plane_size.y / max(size.y - 1, 1)
	var height_scale = update_heightmapshape_values(project.height_data)
	normal_vectors.height_scale = height_scale
	plane_material.set_shader_param("height_scale", height_scale)
	plane_material.set_shader_param("TEXTURE_PIXEL_SIZE", Vector2.ONE / size)


func update_heightmapshape_values(height_data: HeightMapData) -> float:
	var height_scale = min(plane_size.x, plane_size.y) * 0.5
	heightmapshape_collision.shape.map_data = height_data.scaled(height_scale)
	return height_scale


func _on_texture_updated(_texture: Texture, empty_data: bool = false) -> void:
	update_plane_dimensions()
	if normal_vectors.visible:
		normal_vectors.update_all(project.normal_image, project.height_data, empty_data)


func _on_operation_ended(operation, height_data: HeightMapData) -> void:
	var _scale = update_heightmapshape_values(height_data)
	if normal_vectors.visible:
		normal_vectors.update_rect(project.normal_image, project.height_data, operation.cached_rect)
	


func set_alpha_enabled(value: bool) -> void:
	plane_material.set_shader_param("use_alpha", value)


func get_alpha_enabled() -> bool:
	return plane_material.get_shader_param("use_alpha")


func get_light_nodes() -> Array:
	return lights.get_children()


func set_lights_enabled(value: bool) -> void:
	for c in lights.get_children():
		c.visible = value


func get_lights_enabled() -> bool:
	return lights.get_child(0).visible


func set_normal_vectors_enabled(value: bool) -> void:
	normal_vectors.visible = value
	if normal_vectors.visible:
		normal_vectors.update_all(project.normal_image, project.height_data)


func get_normal_vectors_enabled() -> bool:
	return normal_vectors.visible


func _on_Plate_input_event(_camera: Node, event: InputEvent, click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and (event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT) and not event.is_echo():
		if event.is_pressed():
			emit_signal("drag_started", event.button_index, click_position_to_uv(click_position))
		else:
			stop_dragging()
	elif event is InputEventMouseMotion:
		emit_signal("drag_moved", event.relative, click_position_to_uv(click_position))


func click_position_to_uv(click_position: Vector3) -> Vector2:
	var local_click_position = plate.to_local(click_position)
	return Vector2(local_click_position.x, local_click_position.z) / plane_size + Vector2(0.5, 0.5)


func stop_dragging() -> void:
	emit_signal("drag_ended")


func _on_Plate_mouse_exited() -> void:
	stop_dragging()
