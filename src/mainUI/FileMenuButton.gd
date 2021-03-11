# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends MenuButton

enum {
	QUIT,
}


func _ready() -> void:
	var popup = get_popup()
	if OS.get_name() != "HTML5":
		popup.add_item("Quit", QUIT)
		popup.set_item_shortcut(QUIT, load("res://shortcuts/Quit_shortcut.tres"))
	popup.connect("id_pressed", self, "_on_item_pressed")


func _on_item_pressed(id: int) -> void:
	if id == QUIT:
		get_tree().quit()
