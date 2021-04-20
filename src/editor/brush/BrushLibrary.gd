# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

const BrushLibraryItem = preload("res://editor/brush/BrushLibraryItem.tscn")

export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")

onready var _grayscale_albedo_item = $ScrollContainer/FixedCellGridContainer/GrayscaleAlbedoBrushLibraryItem
onready var _brush_item_container = $ScrollContainer/FixedCellGridContainer


func _ready() -> void:
	_on_albedo_texture_changed()
	project.connect("albedo_texture_changed", self, "_on_albedo_texture_changed")


func _on_albedo_texture_changed(_texture: Texture = null, _empty_data = false) -> void:
	var grayscale_albedo = Image.new()
	grayscale_albedo.copy_from(project.albedo_image)
	grayscale_albedo.convert(MapTypes.BRUSH_IMAGE_FORMAT)
	_grayscale_albedo_item.texture.create_from_image(grayscale_albedo, _grayscale_albedo_item.texture.flags)


func _on_ImportButton_pressed() -> void:
	ImageFileDialog.try_load_image(funcref(self, "_on_image_imported"))


func _on_image_imported(image: Image, path: String) -> void:
	var new_item = BrushLibraryItem.instance()
	var texture = ImageTexture.new()
	image.convert(MapTypes.BRUSH_IMAGE_FORMAT)
	texture.create_from_image(image, new_item.HEIGHT_TEXTURE_FLAGS)
	new_item.title = path
	new_item.texture = texture
	new_item.pressed = false
	_brush_item_container.add_child(new_item)
