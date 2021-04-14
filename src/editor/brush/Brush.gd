# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

export(float) var size = 32.0 setget set_size, get_size
export(float, 0, 1) var depth = 1 setget set_depth, get_depth

var _size := 32.0
var _depth := 1.0


func set_size(value: float) -> void:
	if not is_equal_approx(value, _size):
		_size = value
		emit_signal("changed")


func get_size() -> float:
	return _size


func set_depth(value: float) -> void:
	if not is_equal_approx(value, _depth):
		_depth = value
		emit_signal("changed")


func get_depth() -> float:
	return _depth
