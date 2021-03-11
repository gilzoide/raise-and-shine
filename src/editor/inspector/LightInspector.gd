# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

const light_inspector_item: PackedScene = preload("res://editor/inspector/LightInspectorItem.tscn")

onready var container = $VBoxContainer


func _ready() -> void:
	add_item_for_light(PhotoBooth.ambient_light, -1)
	var lights = PhotoBooth.get_light_nodes()
	for i in lights.size():
		add_item_for_light(lights[i], i + 1)


func add_item_for_light(light, index: int) -> void:
	var new_item = light_inspector_item.instance()
	new_item.light = light
	container.add_child(new_item)
	new_item.set_name_index(index)
