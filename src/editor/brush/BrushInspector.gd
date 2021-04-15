# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends VBoxContainer

export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")

onready var _depth_spinbox = $DepthHeader/SpinBox
onready var _depth_slider = $DepthSlider
onready var _size_spinbox = $SizeHeader/SpinBox
onready var _size_slider = $SizeSlider


func _ready() -> void:
	_depth_spinbox.share(_depth_slider)
	_depth_spinbox.value = int(brush.depth * 100)
	_depth_spinbox.connect("value_changed", self, "_on_depth_value_changed")
	
	_size_spinbox.share(_size_slider)
	_size_spinbox.value = brush.size
	_size_spinbox.connect("value_changed", brush, "set_size")


func _on_depth_value_changed(value) -> void:
	brush.depth = value / 100.0
