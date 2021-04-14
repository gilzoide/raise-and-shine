# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, rect_size), Color.white)
#	var center = rect_size * 0.5
#	var radius = min(center.x, center.y)
#	draw_circle(center, radius, Color.white)
