# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends HSplitContainer

export(Resource) var selection = preload("res://editor/selection/ActiveSelection.tres")

onready var maps_container = $MapsContainer
onready var albedo_editor = $MapsContainer/AlbedoMap
onready var height_editor = $MapsContainer/HeightMap
onready var normal_editor = $MapsContainer/NormalMap

onready var visualizers_container = $VisualizersContainer
onready var orthogonal_editor = $VisualizersContainer/Split/OrthogonalVisualizer
onready var perspective_editor = $VisualizersContainer/Split/PerspectiveVisualizer

var _dragging := false


func _ready() -> void:
	var _err
	_err = PhotoBooth.connect("drag_started", self, "_on_drag_started")
	_err = PhotoBooth.connect("drag_moved", self, "_on_drag_moved")
	_err = PhotoBooth.connect("drag_ended", self, "_on_drag_ended")


func collapse_maps_if_needed() -> void:
	maps_container.visible = albedo_editor.visible or height_editor.visible or normal_editor.visible


func set_albedo_visible(value: bool) -> void:
	albedo_editor.visible = value
	collapse_maps_if_needed()


func set_height_visible(value: bool) -> void:
	height_editor.visible = value
	collapse_maps_if_needed()


func set_normal_visible(value: bool) -> void:
	normal_editor.visible = value
	collapse_maps_if_needed()


func collapse_visualizers_if_needed() -> void:
	visualizers_container.visible = orthogonal_editor.visible or perspective_editor.visible


func set_2d_visible(value: bool) -> void:
	orthogonal_editor.visible = value
	collapse_visualizers_if_needed()


func set_3d_visible(value: bool) -> void:
	perspective_editor.visible = value
	collapse_visualizers_if_needed()


func _on_drag_started(button_index, uv) -> void:
	_dragging = true
	selection.set_drag_operation_started(button_index, uv)


func _on_drag_moved(relative_motion, uv) -> void:
	if _dragging:
		selection.set_drag_hovering(relative_motion, uv)


func _on_drag_ended() -> void:
	_dragging = false
	selection.set_drag_operation_ended()
