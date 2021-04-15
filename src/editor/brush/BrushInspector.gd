# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends VBoxContainer

export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")

onready var _size_spinbox = $SizeHeader/SpinBox
onready var _size_slider = $SizeSlider


func _ready() -> void:
	_size_spinbox.share(_size_slider)
	_size_spinbox.value = brush.size
	_size_spinbox.connect("value_changed", brush, "set_size")
