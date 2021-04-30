# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

export(Array, Resource) var versions = []

onready var _richtext = $ScrollContainer/NewsLabel


func _ready() -> void:
	var new_text_array = PoolStringArray()
	for i in range(versions.size() - 1, -1, -1):
		new_text_array.append(versions[i].generate_bbcode())
	var new_text = new_text_array.join("\n\n\n").replace("[url", "[color=#ff8588][url").replace("[/url]", "[/url][/color]")
	_richtext.bbcode_text = new_text
