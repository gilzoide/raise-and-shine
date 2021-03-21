# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Button

export(Resource) var settings = preload("res://settings/DefaultSettings.tres")

onready var _text = text

func _ready() -> void:
	if not settings.show_tool_button_text:
		text = ""
