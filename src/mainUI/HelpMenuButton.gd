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

var AboutPopup: PackedScene = null
var OnboardingPopup: PackedScene = null

onready var menu_popup = get_popup()


func _ready() -> void:
	menu_popup.add_item("Help", HELP)
	menu_popup.add_item("About", ABOUT)
	menu_popup.connect("id_pressed", self, "_on_menu_popup_id_pressed")
	
	settings.load_config()  # TODO: load config in a more appropriate place
	if not settings.should_skip_onboarding_at_startup():
		_on_menu_popup_id_pressed(HELP)


func _on_menu_popup_id_pressed(id: int) -> void:
	if id == HELP:
		if not OnboardingPopup:
			OnboardingPopup = load("res://help/OnboardingPopup.tscn")
		var popup: Popup = OnboardingPopup.instance()
		add_child(popup)
		var _err = popup.connect("popup_hide", popup, "queue_free", [], CONNECT_ONESHOT)
		popup.popup_centered_ratio(0.91)
	elif id == ABOUT:
		if not AboutPopup:
			AboutPopup = load("res://mainUI/AboutPopup.tscn")
		var popup: Popup = AboutPopup.instance()
		add_child(popup)
		var _err = popup.connect("popup_hide", popup, "queue_free", [], CONNECT_ONESHOT)
		popup.popup_centered()
