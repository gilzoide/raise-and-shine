# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
tool
extends Control

export(Texture) var texture setget set_texture, get_texture
export(String) var title setget set_title, get_title

var _texture: Texture
var _title: String
onready var _icon = $HBoxContainer/KeyIcon
onready var _label = $HBoxContainer/KeyLabel


func _ready() -> void:
	_icon.texture = _texture
	_label.text = _title


func set_texture(texture: Texture) -> void:
	_texture = texture
	if _icon:
		_icon.texture = texture


func get_texture() -> Texture:
	return _texture


func set_title(title: String) -> void:
	_title = title
	if _label:
		_label.text = title


func get_title() -> String:
	return _title
