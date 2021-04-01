# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
class_name ControlExtras

const WRAP_MOUSE_META_KEY = "ControlExtras.wrap_mouse"

static func set_cursor(control: Control, cursor: int, now: bool = true):
	var previous = control.mouse_default_cursor_shape
	control.mouse_default_cursor_shape = cursor
	if now and previous != cursor:
		update_cursor(control)


static func update_cursor(control: Control) -> void:
	var event = InputEventMouseMotion.new()
	event.global_position = control.get_global_mouse_position()
	event.position = event.global_position
	Input.call_deferred("parse_input_event", event)


static func wrap_mouse_motion_if_needed(control: Control, mousemotion: InputEventMouseMotion):
	var outside = not Rect2(Vector2.ZERO, control.rect_size).has_point(mousemotion.position)
	if outside:
		mousemotion.position = mousemotion.position.posmodv(control.rect_size)
		control.warp_mouse(mousemotion.position)
	var did_just_warp = control.has_meta(WRAP_MOUSE_META_KEY) and control.get_meta(WRAP_MOUSE_META_KEY)
	if did_just_warp:
		mousemotion.relative = Vector2.ZERO
	control.set_meta(WRAP_MOUSE_META_KEY, outside)
