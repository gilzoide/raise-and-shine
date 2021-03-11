# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

onready var label = $Label


func show_at_position(global_position: Vector2) -> void:
	rect_global_position = global_position - rect_pivot_offset
	visible = true


func update_height(height: float) -> void:
	label.text = "%.2f" % height

