# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

enum Modifier {
	NONE,
	SHIFT,
	CONTROL,
}

export(Modifier) var modifier = Modifier.NONE

onready var _animation = $Fill/AspectRatioContainer/Animation
onready var _key_plus_sign = $ControlIcons/PlusSign
onready var _key_rect = $ControlIcons/Key
onready var _key_icon = $ControlIcons/Key/HBoxContainer/KeyIcon
onready var _key_label = $ControlIcons/Key/HBoxContainer/KeyLabel

func _ready() -> void:
	_animation.modifier = modifier
	if modifier == Modifier.NONE:
		_key_plus_sign.visible = false
		_key_rect.visible = false
	elif modifier == Modifier.SHIFT:
		_key_icon.texture = load("res://textures/ShiftKeyIcon.svg")
		_key_label.text = "Shift"
	elif modifier == Modifier.CONTROL:
		_key_icon.texture = load("res://textures/ControlKeyIcon.svg")
		_key_label.text = "Ctrl"


func set_format(format: int) -> void:
	_animation.set_format(format)
