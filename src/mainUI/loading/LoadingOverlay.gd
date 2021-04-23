# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Popup

export(float) var animation_duration = 1

onready var _icon = $LoadingIcon


func _ready() -> void:
	set_as_toplevel(true)
	set_process(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_process(visible)


func _process(delta: float) -> void:
	_icon.rect_rotation += 360 * delta / animation_duration


func present() -> void:
	popup_centered_ratio(1)


func dismiss() -> void:
	hide()
