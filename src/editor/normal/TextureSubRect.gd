# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

export(Texture) var texture = preload("res://textures/Height_imagetexture.tres")

var subrect: Rect2


func _draw() -> void:
	draw_texture_rect_region(texture, subrect, subrect)
