# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

export(float) var size = 32.0 setget set_size, get_size

var _size := 32.0


func set_size(value: float) -> void:
	if value != _size:
		_size = value
		emit_signal("changed")


func get_size() -> float:
	return _size
