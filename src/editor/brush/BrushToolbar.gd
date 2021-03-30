# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends PanelContainer

export(Resource) var selection = preload("res://editor/selection/ActiveSelection.tres")


func _on_tool_button_pressed(op: int) -> void:
	selection.set_active_tool(op)
