# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

export(SelectionBitMap.Format) var format = SelectionBitMap.Format.RECTANGLE
export(Rect2) var rect = Rect2()
var bitmap: SelectionBitMap = SelectionBitMap.new()


func set_rect(r: Rect2, line_direction: float = 1.0) -> void:
	assert(not r.has_no_area(), "Trying to set a selection with no area!!!")
	if format == SelectionBitMap.Format.PENCIL or not rect.size.is_equal_approx(r.size):
		bitmap.create_format(r.size, line_direction, format)
	rect = r


func paint_position(position: Vector2) -> void:
	bitmap.set_bit(position, true)


func blit_to_image(image: Image) -> void:
	bitmap.blit_to_image(image, rect.position)
