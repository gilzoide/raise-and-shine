# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")

onready var _normal_invert_y = $NormalLabel/InvertYCheckBox


func _ready() -> void:
	_normal_invert_y.pressed = NormalDrawer.invert_y
	PhotoBooth.take_screenshot()


func _on_AlbedoExportButton_pressed() -> void:
	project.save_image_dialog_type(MapTypes.Type.ALBEDO_MAP)


func _on_HeightExportButton_pressed() -> void:
	project.save_image_dialog_type(MapTypes.Type.HEIGHT_MAP)


func _on_NormalExportButton_pressed() -> void:
	project.save_image_dialog_type(MapTypes.Type.NORMAL_MAP)


func _on_IlluminatedExportButton_pressed() -> void:
	project.save_image_dialog_type(MapTypes.Type.ILLUMINATED_MAP)


func _on_InvertYCheckBox_toggled(button_pressed: bool) -> void:
	NormalDrawer.invert_y = button_pressed
