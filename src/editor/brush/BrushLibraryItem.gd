# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
tool
extends Button

const EMPTY_TEXTURE = preload("res://textures/pixel.png")

export(String) var title := "" setget set_title, get_title
export(Texture) var texture: Texture = EMPTY_TEXTURE setget set_texture, get_texture
export(bool) var builtin = false
export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")

var _title: String
var _texture: Texture
onready var _label = $Container/Label
onready var _texture_rect = $Container/TextureRect


func _ready() -> void:
	_label.text = _title
	_texture_rect.texture = _texture


func _pressed() -> void:
	brush.texture = _texture


func set_title(value: String) -> void:
	_title = value
	if _label:
		_label.text = value


func get_title() -> String:
	return _title


func set_texture(value: Texture) -> void:
	if not value:
		value = EMPTY_TEXTURE
	_texture = value
	if _texture_rect:
		_texture_rect.texture = value


func get_texture() -> Texture:
	return _texture
