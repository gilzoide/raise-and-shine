# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

const SETTINGS_FILE_PATH = "user://settings.ini"

const SECTION_COLOR = "color"
const SECTION_COLOR_BACKGROUND = "background"
const SECTION_ONBOARDING = "onboarding"
const SECTION_ONBOARDING_SKIP = "skip"

export(Color) var background_color := Color("4d4d4d")
export(bool) var show_tool_button_text := false
export(bool) var skip_onboarding_at_startup := false

var _config_file := ConfigFile.new()

func load_config() -> void:
	if _config_file.load(SETTINGS_FILE_PATH) == OK:
		if _config_file.has_section_key(SECTION_COLOR, SECTION_COLOR_BACKGROUND):
			var value = _config_file.get_value(SECTION_COLOR, SECTION_COLOR_BACKGROUND)
			if value is Color:
				background_color = value
		if _config_file.has_section_key(SECTION_ONBOARDING, SECTION_ONBOARDING_SKIP):
			var value = _config_file.get_value(SECTION_ONBOARDING, SECTION_ONBOARDING_SKIP)
			skip_onboarding_at_startup = bool(value)


func can_save() -> bool:
	return OS.is_userfs_persistent()


func set_skip_onboarding_at_startup(value: bool) -> void:
	_config_file.set_value(SECTION_ONBOARDING, SECTION_ONBOARDING_SKIP, value)
	call_deferred("_save_config_file")


func _save_config_file() -> void:
	if can_save():
		if _config_file.save(SETTINGS_FILE_PATH) != OK:
			print("Saving ", SETTINGS_FILE_PATH, " failed")
