# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

const BrushLibraryItem = preload("res://editor/brush/BrushLibraryItem.gd")
const BrushLibraryItemScene = preload("res://editor/brush/BrushLibraryItem.tscn")

export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")

var _item_per_path = {}
onready var _grayscale_albedo_item = $ScrollContainer/FixedCellGridContainer/GrayscaleAlbedoBrushLibraryItem
onready var _brush_item_container = $ScrollContainer/FixedCellGridContainer


func _ready() -> void:
	_on_albedo_texture_changed()
	project.connect("albedo_texture_changed", self, "_on_albedo_texture_changed")


func _on_albedo_texture_changed(_texture: Texture = null, _empty_data = false) -> void:
	_grayscale_albedo_item.texture.create_from_image(project.albedo_image, BrushLibraryItem.HEIGHT_TEXTURE_FLAGS)


func _on_ImportButton_pressed() -> void:
	ImageFileDialog.try_load_image(funcref(self, "_on_image_imported"))


func _on_image_imported(image: Image, path: String) -> void:
	var brush_item = _item_per_path.get(path)
	if not brush_item:
		brush_item = BrushLibraryItemScene.instance()
		brush_item.texture = ImageTexture.new()
		brush_item.title = path
		brush_item.pressed = false
		_item_per_path[path] = brush_item
		_brush_item_container.add_child(brush_item)
	brush_item.texture.create_from_image(image, BrushLibraryItem.HEIGHT_TEXTURE_FLAGS)
