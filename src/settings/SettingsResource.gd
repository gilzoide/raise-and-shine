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
const SECTION_VERSION = "version"
const SECTION_VERSION_LATEST_NEWS_SEEN = "latest_news_seen"

const ChangelogVersion = preload("res://changelog/ChangelogVersion.gd")

export(Color) var background_color := Color("4d4d4d")
export(bool) var show_tool_button_text := false
export(bool) var skip_onboarding_at_startup := false
export(int) var latest_news_version_seen = 0

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
		if _config_file.has_section_key(SECTION_VERSION, SECTION_VERSION_LATEST_NEWS_SEEN):
			var value = _config_file.get_value(SECTION_VERSION, SECTION_VERSION_LATEST_NEWS_SEEN)
			latest_news_version_seen = int(value)


func can_save() -> bool:
	return OS.is_userfs_persistent()


func set_skip_onboarding_at_startup(value: bool) -> void:
	_config_file.set_value(SECTION_ONBOARDING, SECTION_ONBOARDING_SKIP, value)
	call_deferred("_save_config_file")
	emit_signal("changed")


func mark_latest_news_seen_version(value: int) -> void:
	_config_file.set_value(SECTION_VERSION, SECTION_VERSION_LATEST_NEWS_SEEN, value)
	call_deferred("_save_config_file")
	emit_signal("changed")


func should_skip_onboarding_at_startup() -> bool:
	return skip_onboarding_at_startup and latest_news_version_seen >= ChangelogVersion.CURRENT_VERSION


func _save_config_file() -> void:
	if can_save():
		if _config_file.save(SETTINGS_FILE_PATH) != OK:
			print("Saving ", SETTINGS_FILE_PATH, " failed")
