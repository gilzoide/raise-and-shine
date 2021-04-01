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
const quad_material = preload("res://editor/visualizers/3D/Quad_material.tres")
const operation = preload("res://editor/operation/DragOperation.tres")
const selection = preload("res://editor/selection/ActiveSelection.tres")
const LightPoint = preload("res://editor/visualizers/LightPoint.tscn")

export(float) var plate_angular_speed = 0.01
export(float) var plane_subdivide_scale = 1

var lights_enabled: bool setget set_lights_enabled, get_lights_enabled
var normal_vectors_enabled: bool setget set_normal_vectors_enabled, get_normal_vectors_enabled

var albedo_size: Vector2
onready var plate = $Plate
onready var plane_mesh_instance = $Plate/Model
onready var quad_mesh_instance = $Plate/QuadModel
onready var border = $Plate/Border
onready var lights = $Lights
onready var ambient_light = $WorldEnvironment
onready var normal_vectors = $Plate/Model/NormalVectorsMultiMeshInstance
onready var initial_plane_size = plane_mesh_instance.mesh.size
onready var plane_size = initial_plane_size
onready var screenshot_viewport = $ScreenshotViewport
onready var screenshot_camera = $ScreenshotViewport/Camera

func _ready() -> void:
	plane_material.set_shader_param("normal_map", NormalDrawer.get_texture())
	_on_albedo_texture_changed(project.albedo_texture)
	_on_height_texture_changed(project.height_texture)
	var _err = project.connect("height_texture_changed", self, "_on_height_texture_changed")
	_err = project.connect("albedo_texture_changed", self, "_on_albedo_texture_changed")


func _on_albedo_texture_changed(texture: Texture, _empty_data: bool = false) -> void:
	albedo_size = texture.get_size()
	if albedo_size.x > albedo_size.y:
		plane_size.x = initial_plane_size.x
		plane_size.y = initial_plane_size.y / albedo_size.aspect()
	else:
		plane_size.x = initial_plane_size.x * albedo_size.aspect()
		plane_size.y = initial_plane_size.y
	
	border.setup_with_plane_size(plane_size)
	normal_vectors.set_plane_size(plane_size)
	
	var height_scale = min(plane_size.x, plane_size.y) * 0.5
	plane_material.set_shader_param("height_scale", height_scale)
	normal_vectors.set_height_scale(height_scale)


func _on_height_texture_changed(texture: Texture, _empty_data: bool = false) -> void:
	var size = texture.get_size()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.subdivide_width = size.x * plane_subdivide_scale
	plane_mesh.subdivide_depth = size.y * plane_subdivide_scale
	plane_mesh.size = plane_size
	plane_mesh_instance.mesh = plane_mesh
	
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = plane_size
	quad_mesh_instance.mesh = quad_mesh
	
	normal_vectors.set_map_size(size)


func get_light_nodes() -> Array:
	return lights.get_children()


func set_lights_enabled(value: bool) -> void:
	lights.visible = value


func get_lights_enabled() -> bool:
	return lights.visible


func add_light():
	var new_light = LightPoint.instance()
	lights.add_child(new_light)
	return new_light


func set_normal_vectors_enabled(value: bool) -> void:
	normal_vectors.visible = value


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


func take_screenshot() -> void:
	screenshot_viewport.size = albedo_size
	screenshot_camera.size = plane_size.y
	screenshot_viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	yield(VisualServer, "frame_post_draw")
	var image = screenshot_viewport.get_texture().get_data()
	project.save_image_dialog(image, "_lit")
