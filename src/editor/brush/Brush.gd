# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

const EMPTY_TEXTURE = preload("res://textures/pixel.png")

export(float) var size = 32.0 setget set_size
export(float, 0, 100) var depth = 100 setget set_depth
export(Texture) var texture: Texture = EMPTY_TEXTURE setget set_texture


func set_size(value: float) -> void:
	if value != size:
		size = value
		emit_signal("changed")


func set_depth(value: float) -> void:
	if value != depth:
		depth = value
		emit_signal("changed")


func set_texture(value: Texture) -> void:
	if not value:
		value = EMPTY_TEXTURE
	if value != texture:
		texture = value
		emit_signal("changed")


func get_depth01() -> float:
	return depth / 100.0
