# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
class_name ControlExtras

static func set_cursor_now(control: Control, cursor: int):
	control.mouse_default_cursor_shape = cursor
	update_cursor(control)

static func update_cursor(control: Control) -> void:
	var event = InputEventMouseMotion.new()
	event.global_position = control.get_global_mouse_position()
	event.position = event.global_position
	Input.call_deferred("parse_input_event", event)
