# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")

onready var _grayscale_albedo_item = $GridContainer/GrayscaleAlbedoBrushLibraryItem


func _ready() -> void:
	_on_albedo_texture_changed()
	project.connect("albedo_texture_changed", self, "_on_albedo_texture_changed")


func _on_albedo_texture_changed(_texture: Texture = null, _empty_data = false) -> void:
	var grayscale_albedo = Image.new()
	grayscale_albedo.copy_from(project.albedo_image)
	grayscale_albedo.convert(Image.FORMAT_LA8)
	_grayscale_albedo_item.texture.create_from_image(grayscale_albedo, _grayscale_albedo_item.texture.flags)
