# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

export(float) var animation_duration = 5
export(float) var animation_delay = 1

var _timer = 0
onready var _visualizer = $OrthogonalVisualizer


func _ready() -> void:
	set_process(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			_timer = 0
			_visualizer.reset_camera()
		set_process(visible)


func _process(delta: float) -> void:
	_timer += delta
	if _timer >= animation_duration + animation_delay:
		_timer = -animation_delay
	
	var percent = _timer / animation_duration
	_visualizer.zoom_to(percent)
