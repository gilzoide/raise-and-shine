# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends VBoxContainer

export(float) var animation_duration = 5
export(float) var animation_delay = 1

var _speed = 1
var _timer = 0

onready var _animation_container = $PerspectiveVisualizer
onready var _model = $PerspectiveVisualizer/ViewportContainer/Viewport/Model
onready var _material: ShaderMaterial = _model.material_override
onready var _cursor_icon = $PerspectiveVisualizer/CursorIcon
onready var _operation: HeightOperation = $PanelContainer/HBoxContainer/BrushDirectionPickerButton.operation


func _ready() -> void:
	set_process(false)
	var _err = _operation.connect("changed", self, "update_material_operation")
	update_material_operation()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			_timer = 0
			_speed = 1
		set_process(visible)


func _process(delta: float) -> void:
	_timer += _speed * delta
	if _timer >= animation_duration + animation_delay or _timer <= -animation_delay:
		_speed = -_speed
		_timer = clamp(_timer, -animation_delay, animation_duration + animation_delay)
	
	var percent = clamp(_timer / animation_duration, 0, 1)
	_cursor_icon.position = _animation_container.rect_size * lerp(Vector2(0.7, 0.7), Vector2(0.7, 0.3), percent)
	_material.set_shader_param("height", percent)


func update_material_operation() -> void:
	_material.set_shader_param("is_flat", _operation.is_flat)
	_material.set_shader_param("direction", _operation.direction)
	_material.set_shader_param("control1", _operation.bezier.control1)
	_material.set_shader_param("control2", _operation.bezier.control2)
