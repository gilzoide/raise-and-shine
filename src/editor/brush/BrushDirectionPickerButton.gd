# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Button

export(Resource) var operation = preload("res://editor/operation/DragOperation.tres")
export(Texture) var arrow = preload("res://textures/ArrowIcon.svg")
export(float) var circle_margin = 4

onready var popup: Popup = $PanelPopup
onready var flat_checkbox = $PanelPopup/VBoxContainer/FlatCheckBox
onready var controls_container = $PanelPopup/VBoxContainer/HBoxContainer
onready var bezier_curve = $PanelPopup/VBoxContainer/HBoxContainer/AspectRatioContainer/Panel/CubicBezierEdit.curve
onready var direction_chooser = $PanelPopup/VBoxContainer/HBoxContainer/DirectionChooser
onready var preview_material = $Preview.material


func _ready() -> void:
	flat_checkbox.pressed = operation.is_flat
	var _err = operation.connect("changed", self, "update_material_operation")
	update_material_operation()


func _draw() -> void:
	var center = rect_size * 0.5
	if operation.is_radial_direction(operation.direction):
		draw_circle(center, min(center.x, center.y) - circle_margin, Color.white)
	else:
		draw_set_transform(center, operation.direction, Vector2.ONE)
		var arrow_size = arrow.get_size()
		draw_texture_rect(arrow, Rect2(-arrow_size * 0.5, arrow_size), false)
	

func _on_pressed() -> void:
	var global_rect = get_global_rect()
	var point = Vector2(global_rect.position.x - popup.rect_size.x * 0.5, global_rect.position.y + global_rect.size.y)
	controls_container.visible = not flat_checkbox.pressed
	popup.popup(Rect2(point, popup.rect_size))


func _on_direction_changed(direction) -> void:
	operation.set_direction(direction)
	update()


func _on_FlatCheckBox_toggled(button_pressed: bool) -> void:
	operation.set_flat(button_pressed)
	controls_container.visible = not operation.is_flat


func _on_control_changed() -> void:
	operation.bezier.copy_from(bezier_curve)


func _on_preset_chosen(curve) -> void:
	bezier_curve.copy_from(curve)
	operation.bezier.copy_from(curve)


func update_material_operation() -> void:
	preview_material.set_shader_param("is_flat", operation.is_flat)
	preview_material.set_shader_param("direction", operation.direction)
	preview_material.set_shader_param("control1", operation.bezier.control1)
	preview_material.set_shader_param("control2", operation.bezier.control2)
