# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

const HEIGHT_TEXTURE_FLAGS = Texture.FLAG_FILTER
const SELECTION_TEXTURE_FLAGS = 0

signal revision_pressed(id)

onready var button = $Button
onready var texture_rect = $Button/TextureRect
var revision_id


func set_revision(revision) -> void:
	revision_id = revision.id
	var height_texture = ImageTexture.new()
	height_texture.create_from_image(revision.heightmap, HEIGHT_TEXTURE_FLAGS)
	texture_rect.texture = height_texture


func set_current() -> void:
	button.pressed = true


func _on_Button_pressed() -> void:
	emit_signal("revision_pressed", revision_id)
