# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
tool
extends Container

export(float) var spacing = 16
export(bool) var union_selection = true

onready var _animation = $Animation
onready var _control_icons = $ControlIcons
onready var _control_mouse_icon = $ControlIcons/MouseIcon


func _ready() -> void:
	_control_mouse_icon.flip_h = not union_selection
	_animation.set_selection_union(union_selection)


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var mouse_icon_size = _control_mouse_icon.texture.get_size()
		var sparing_height = rect_size.y - mouse_icon_size.y - spacing
		var animation_side = min(sparing_height, rect_size.x)
		var animation_origin = Vector2(rect_size.x - animation_side, 0) * 0.5
		var animation_rect = Rect2(animation_origin, Vector2(animation_side, animation_side))
		fit_child_in_rect(_animation, animation_rect)
		var controls_rect = Rect2(0, animation_rect.end.y + spacing, rect_size.x, mouse_icon_size.y)
		fit_child_in_rect(_control_icons, controls_rect)


func set_format(format: int) -> void:
	_animation.set_format(format)
