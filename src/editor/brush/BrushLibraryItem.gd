# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
tool
extends Button

enum {
	REMOVE,
	SHOW_FILE_MANAGER,
}

const HEIGHT_TEXTURE_FLAGS = Texture.FLAG_FILTER
const EMPTY_TEXTURE = preload("res://textures/pixel.png")

export(String) var title := "" setget set_title
export(String) var path := "" setget set_path
export(Texture) var texture: Texture = EMPTY_TEXTURE setget set_texture
export(bool) var builtin = false
export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")

var _context_menu: PopupMenu = null
onready var _label = $Container/Label
onready var _texture_rect = $Container/TextureRect


func _ready() -> void:
	_label.text = title
	_texture_rect.texture = texture
	
	if not builtin:
		_context_menu = PopupMenu.new()
		_context_menu.add_item("Remove", REMOVE)
		_context_menu.set_item_tooltip(REMOVE, "Remove brush from library")
		if ProjectSettings.get_setting("global/brush_library_track_files"):
			_context_menu.add_item("Show in File Manager", SHOW_FILE_MANAGER)
		var _err = _context_menu.connect("id_pressed", self, "_on_context_menu_id_pressed")
		add_child(_context_menu)


func _gui_input(event: InputEvent) -> void:
	if _context_menu and event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.is_pressed():
		_context_menu.popup(Rect2(event.global_position, _context_menu.rect_size))


func _pressed() -> void:
	brush.texture = texture


func set_title(value: String) -> void:
	title = value
	if path.empty():
		hint_tooltip = value
	if _label:
		_label.text = value


func set_path(value: String) -> void:
	path = value
	hint_tooltip = value


func set_texture(value: Texture) -> void:
	if not value:
		value = EMPTY_TEXTURE
	texture = value
	if _texture_rect:
		_texture_rect.texture = value


func _on_context_menu_id_pressed(id: int) -> void:
	if id == REMOVE:
		get_parent().remove_child(self)
		queue_free() 
	elif id == SHOW_FILE_MANAGER:
		var _err = OS.shell_open(path.get_base_dir())
