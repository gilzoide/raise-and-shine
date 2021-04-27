# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

signal size_changed()

const EMPTY_TEXTURE = preload("res://textures/pixel.png")

export(float) var size = 32.0 setget set_size
export(float, 0, 100) var pressure = 100 setget set_pressure
export(float, -180, 180) var angle = 0 setget set_angle
export(Texture) var texture: Texture = EMPTY_TEXTURE setget set_texture
export(CanvasItemMaterial) var material: CanvasItemMaterial = preload("res://editor/height/BrushHeight_material.tres")

var uv: Vector2 setget set_uv
var uv_snap_to_size: Vector2 setget set_uv_snap_to_size
var visible := false setget set_visible
var erasing := false setget set_erasing

var _inv_uv_snap_to_size: Vector2


func set_size(value: float) -> void:
	if value != size:
		size = value
		emit_signal("size_changed")
		emit_signal("changed")


func set_pressure(value: float) -> void:
	if value != pressure:
		pressure = value
		emit_signal("changed")


func set_angle(value: float) -> void:
	if value != angle:
		angle = value
		emit_signal("changed")


func set_texture(value: Texture) -> void:
	if not value:
		value = EMPTY_TEXTURE
	if value != texture:
		texture = value
		emit_signal("changed")


func set_uv(value: Vector2) -> void:
	var pos = (value * uv_snap_to_size).floor() + Vector2(0.5, 0.5)
	value = pos * _inv_uv_snap_to_size
	if not value.is_equal_approx(uv):
		uv = value
		emit_signal("changed")


func set_uv_snap_to_size(value: Vector2) -> void:
	if value != uv_snap_to_size:
		uv_snap_to_size = value
		_inv_uv_snap_to_size = Vector2.ONE / value


func set_visible(value: bool) -> void:
	if value != visible:
		visible = value
		emit_signal("changed")


func set_erasing(value: bool) -> void:
	if value != erasing:
		erasing = value
		emit_signal("changed")


func get_pressure01() -> float:
	return pressure / 100.0
