# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

export(Resource) var settings = preload("res://settings/DefaultSettings.tres")

onready var show_on_startup_checkbox: CheckBox = $ShowOnStartCheckBox


func _ready() -> void:
	show_on_startup_checkbox.visible = settings.can_save()
	show_on_startup_checkbox.pressed = not settings.skip_onboarding_at_startup


func _on_ShowOnStartCheckBox_toggled(button_pressed: bool) -> void:
	settings.set_skip_onboarding_at_startup(not button_pressed)
