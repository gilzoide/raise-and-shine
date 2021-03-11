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
