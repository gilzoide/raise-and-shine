# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

export(float) var speed: float = 1
export(float) var faster_factor: float = 5
export(float) var zoom_speed: float = 0.01
export(Resource) var selection = preload("res://editor/selection/ActiveSelection.tres")
export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")

onready var viewport: Viewport = $ViewportContainer/Viewport
onready var camera: Camera = $ViewportContainer/Viewport/Camera
onready var zoom_slider = $ZoomSlider
onready var camera_initial_transform: Transform = camera.transform
var panning := false
var dragging := false
var is_erasing := false
var current_zoom = 0
var in_notification := false


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("visualizer_zoom_up"):
		var factor = (faster_factor if Input.is_action_pressed("visualizer_3d_faster") else 1.0) * zoom_speed
		zoom_by(factor)
	elif event.is_action_pressed("visualizer_zoom_down"):
		var factor = (faster_factor if Input.is_action_pressed("visualizer_3d_faster") else 1.0) * zoom_speed
		zoom_by(-factor)
	elif event.is_action("visualizer_pan_modifier"):
		if event.is_pressed():
			set_pan_cursor()
		else:
			set_normal_cursor()
	elif event.is_action_pressed("visualizer_reset"):
		reset_camera()
	elif event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_MIDDLE or Input.is_action_pressed("visualizer_pan_modifier"):
				start_panning()
				return  # avoid processing input in viewport
			elif event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT:
				start_dragging(event.button_index)
		else:
			if panning:
				stop_panning()
			if dragging:
				stop_dragging()
	elif event is InputEventMouseMotion:
		if panning:
			ControlExtras.wrap_mouse_motion_if_needed(self, event)
			pan_by_mouse(event.relative, Input.is_action_pressed("visualizer_3d_faster"))
			return  # avoid processing input in viewport
		if dragging:
			ControlExtras.wrap_mouse_motion_if_needed(self, event)
			HeightDrawer.draw_brush_centered_uv(brush, PhotoBooth.last_hovered_uv, is_erasing)
#			selection.set_drag_hovering(event.relative, PhotoBooth.last_hovered_uv)
	viewport.unhandled_input(event)
	


func pan_by_mouse(relative: Vector2, faster: bool = false) -> void:
	var factor = (faster_factor if faster else 1.0)
	update_camera_with_pan(relative * factor)


func start_panning() -> void:
	panning = true
	grab_focus()
	set_pan_cursor()
	if OS.get_name() != "HTML5":
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func stop_panning() -> void:
	panning = false
	set_normal_cursor()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func start_dragging(button_index: int) -> void:
	dragging = true
	is_erasing = button_index == BUTTON_RIGHT
	if is_erasing:
		BrushDrawer.erase_brush()
	HeightDrawer.draw_brush_centered_uv(brush, PhotoBooth.last_hovered_uv, is_erasing)
#	set_drag_cursor()
#	selection.set_drag_operation_started(button_index, PhotoBooth.last_hovered_uv)


func stop_dragging() -> void:
	dragging = false
	if is_erasing:
		BrushDrawer.draw_brush()
#	set_normal_cursor()
#	selection.set_drag_operation_ended()


func set_pan_cursor() -> void:
	ControlExtras.set_cursor(self, Control.CURSOR_MOVE, not in_notification)


func set_drag_cursor() -> void:
	ControlExtras.set_cursor(self, selection.get_cursor_for_active_tool(), not in_notification)


func set_normal_cursor() -> void:
	ControlExtras.set_cursor(self, Control.CURSOR_ARROW, not in_notification)


func zoom_by(factor: float) -> void:
	zoom_to(current_zoom + factor)


func zoom_to(zoom: float) -> void:
	zoom_slider.value = zoom
	current_zoom = clamp(zoom, 0, 1)
	set_camera_zoom_percent(current_zoom)


func _notification(what: int) -> void:
	in_notification = true
	if what == NOTIFICATION_FOCUS_ENTER:
		set_process(true)
	elif what == NOTIFICATION_FOCUS_EXIT:
		set_process(false)
	elif what == NOTIFICATION_MOUSE_ENTER:
		grab_focus()
		PhotoBooth.set_brush_visible(true)
	elif what == NOTIFICATION_MOUSE_EXIT:
		stop_panning()
		release_focus()
		PhotoBooth.set_brush_visible(false)
	in_notification = false


func update_camera_with_pan(_pan: Vector2) -> void:
	assert(false, "Implement me!!!")


func set_camera_zoom_percent(_percent: float) -> void:
	assert(false, "Implement me!!!")


func reset_camera() -> void:
	zoom_to(0)
	camera.transform = camera_initial_transform
