# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends PanelContainer

export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")

onready var _brush_preview = $HBoxContainer/Preview/BrushHover2D
onready var _brush_size_editor = $HBoxContainer/BrushSizeEditor


func _ready() -> void:
	var _err = brush.connect("changed", self, "_on_brush_changed")
	_err = HeightDrawer.connect("size_changed", self, "_on_height_drawer_size_changed")


func _on_brush_changed() -> void:
	_brush_preview.rotation_degrees = -brush.angle


func _on_height_drawer_size_changed() -> void:
	var max_value = max(max(HeightDrawer.size.x, HeightDrawer.size.y), BrushDrawer.minimum_size)
	_brush_size_editor.set_max_value(max_value)
