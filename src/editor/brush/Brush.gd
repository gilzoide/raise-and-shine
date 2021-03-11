# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

export(BitMapPlus.Format) var format = BitMapPlus.Format.RECTANGLE
export(Rect2) var rect = Rect2()
var bitmap: BitMapPlus = BitMapPlus.new()


func set_rect(r: Rect2, line_direction: float) -> void:
	if not rect.size.is_equal_approx(r.size) and not r.has_no_area():
		bitmap.create_format(r.size, line_direction, format)
	rect = r


func blit_to_image(image: Image) -> void:
	bitmap.blit_to_image(image, rect.position)
