# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
tool
extends Button

const HEIGHT_TEXTURE_FLAGS = Texture.FLAG_FILTER
const EMPTY_TEXTURE = preload("res://textures/pixel.png")

export(String) var title := "" setget set_title
export(Texture) var texture: Texture = EMPTY_TEXTURE setget set_texture
export(bool) var builtin = false
export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")

onready var _label = $Container/Label
onready var _texture_rect = $Container/TextureRect


func _ready() -> void:
	_label.text = title
	_texture_rect.texture = texture


func _pressed() -> void:
	brush.texture = texture


func set_title(value: String) -> void:
	title = value
	hint_tooltip = value
	if _label:
		_label.text = value


func set_texture(value: Texture) -> void:
	if not value:
		value = EMPTY_TEXTURE
	texture = value
	if _texture_rect:
		_texture_rect.texture = value
