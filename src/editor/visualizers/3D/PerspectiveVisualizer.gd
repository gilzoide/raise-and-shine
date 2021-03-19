# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends "res://editor/visualizers/VisualizerContainer.gd"

export(float) var min_zoom_distance: float = 128
export(float) var max_zoom_distance: float = 4

var _zoom_distance := min_zoom_distance

func _ready() -> void:
	update_camera_with_pan(Vector2(0, -80))
	camera_initial_transform = camera.global_transform


func _process(delta: float) -> void:
	if has_focus():
		var factor = (faster_factor if Input.is_action_pressed("visualizer_3d_faster") else 1.0) * delta
		var movement = Vector2(
			Input.get_action_strength("visualizer_3d_rotate_left") - Input.get_action_strength("visualizer_3d_rotate_right"),
			Input.get_action_strength("visualizer_3d_rotate_up") - Input.get_action_strength("visualizer_3d_rotate_down")
		)
		var clockwise = Input.get_action_strength("visualizer_3d_rotate_clockwise") - Input.get_action_strength("visualizer_3d_rotate_counterclockwise")
		update_camera_with_pan(movement * speed * factor, clockwise * factor)


func update_camera_with_pan(pan: Vector2, angle: float = 0) -> void:
	pan *= _zoom_distance / min_zoom_distance
	var pan3d = Vector3(-pan.x, pan.y, 0)
	var panned: Vector3 = camera.transform.xform(pan3d)
	var position = panned.normalized() * camera.translation.length()
	var up = camera.transform.basis.xform(Vector3.UP).rotated(Vector3.FORWARD, -angle)
	camera.look_at_from_position(position, Vector3.ZERO, up)


func set_camera_zoom_percent(percent: float) -> void:
	var direction = camera.translation.normalized()
	_zoom_distance = lerp(min_zoom_distance, max_zoom_distance, percent)
	camera.translation = direction * _zoom_distance
