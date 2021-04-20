# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
class_name MapTypes

extends Object

enum Type {
	ALBEDO_MAP,
	HEIGHT_MAP,
	NORMAL_MAP,
}

const ALBEDO_TEXTURE = preload("res://textures/Albedo_imagetexture.tres")
const ALBEDO_SRGB_TEXTURE = preload("res://textures/Albedo_SRGB_imagetexture.tres")
const HEIGHT_TEXTURE = preload("res://textures/Height_imagetexture.tres")
const NORMAL_TEXTURE = preload("res://textures/Normal_imagetexture.tres")

const BRUSH_IMAGE_FORMAT = Image.FORMAT_LA8
const HEIGHT_IMAGE_FORMAT = Image.FORMAT_L8
const NORMAL_IMAGE_FORMAT = Image.FORMAT_RGB8


static func map_name(type: int) -> String:
	if type == Type.ALBEDO_MAP:
		return "Albedo"
	elif type == Type.HEIGHT_MAP:
		return "Height"
	elif type == Type.NORMAL_MAP:
		return "Normal"
	else:
		assert(false, "Unknown map type %d" % type)
		return ""


static func map_textures(type: int) -> Array:
	if type == Type.ALBEDO_MAP:
		if OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES3:
			return [ALBEDO_SRGB_TEXTURE, ALBEDO_TEXTURE]
		else:
			return [ALBEDO_TEXTURE]
	elif type == Type.HEIGHT_MAP:
		return [HeightDrawer.get_texture(), HEIGHT_TEXTURE]
	elif type == Type.NORMAL_MAP:
		return [NormalDrawer.get_texture(), NORMAL_TEXTURE]
	else:
		assert(false, "Unknown map type %d" % type)
		return []

