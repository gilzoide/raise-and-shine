# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends MenuButton

enum {
	HELP,
	ABOUT,
}

export(Resource) var settings = preload("res://settings/DefaultSettings.tres")

var about_popup: Popup = null
var onboarding_popup: Popup = null

onready var menu_popup = get_popup()


func _ready() -> void:
	menu_popup.add_item("Help", HELP)
	menu_popup.add_item("About", ABOUT)
	menu_popup.connect("id_pressed", self, "_on_menu_popup_id_pressed")
	
	settings.load_config()  # TODO: load config in a more appropriate place
	if not settings.skip_onboarding_at_startup:
		_on_menu_popup_id_pressed(HELP)


func _on_menu_popup_id_pressed(id: int) -> void:
	if id == HELP:
		if not onboarding_popup:
			onboarding_popup = load("res://help/OnboardingPopup.tscn").instance()
			add_child(onboarding_popup)
		onboarding_popup.popup_centered_ratio(0.9)
	elif id == ABOUT:
		if about_popup == null:
			about_popup = load("res://mainUI/AboutPopup.tscn").instance()
			add_child(about_popup)
		about_popup.popup_centered()
