# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Button

export(Resource) var operation = preload("res://editor/operation/DragOperation.tres")
export(Texture) var arrow = preload("res://textures/ArrowIcon.svg")
export(float) var circle_margin = 4

onready var popup: Popup = $PanelPopup


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
	var point = Vector2(global_rect.position.x, global_rect.position.y + global_rect.size.y)
	popup.popup(Rect2(point, popup.rect_size))


func _on_PanelPopup_direction_changed(_direction) -> void:
	update()
