# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Node2D

export(Texture) var texture: Texture = null setget set_texture

onready var _quad = $Quad


func _ready() -> void:
	set_texture(texture)
	_quad.texture = texture


func set_texture(value: Texture) -> void:
	if not value:
		value = BrushDrawer.get_texture()
	if value != texture:
		texture = value
		if _quad:
			_quad.texture = texture
