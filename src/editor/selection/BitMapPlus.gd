extends BitMap

class_name BitMapPlus

const TRUE_COLOR = Color.white
const FALSE_COLOR = Color.black

enum Format {
	RECTANGLE,
	ELLIPSE,
}

func copy_from(bitmap: BitMap) -> void:
	data = bitmap.data

func create_image() -> Image:
	var image = Image.new()
	var size = get_size()
	image.create(size.x, size.y, false, Image.FORMAT_L8)
	blit_to_image(image)
	return image

func blit_to_image(image: Image, dst: Vector2 = Vector2.ZERO) -> void:
	var self_size = get_size()
	var image_size = image.get_size()
	image.lock()
	for x in min(self_size.x - dst.x, image_size.x):
		for y in min(self_size.y - dst.y, image_size.y):
			image.set_pixel(x, y, TRUE_COLOR if get_bit(Vector2(x, y)) else FALSE_COLOR)
	image.unlock()

func blend_or(bitmap: BitMap, dst: Vector2) -> void:
	var self_size = get_size()
	var bitmap_size = bitmap.get_size()
	for x in min(self_size.x - dst.x, bitmap_size.x):
		for y in min(self_size.y - dst.y, bitmap_size.y):
			var v = Vector2(x, y)
			var dst_v = dst + v
			set_bit(dst_v, get_bit(dst_v) or bitmap.get_bit(v))

func create_format(size: Vector2, format: int) -> void:
	create(size)
	if format == Format.RECTANGLE:
		set_bit_rect(Rect2(Vector2.ZERO, size), true)
	elif format == Format.ELLIPSE:
		var half_size = size / 2
		var squared_size_x = half_size.x * half_size.x
		var squared_size_y = half_size.y * half_size.y
		for x in size.x:
			for y in size.y:
				var centered_x = x - half_size.x
				var centered_y = y - half_size.y
				set_bit(Vector2(x, y), (centered_x * centered_x) / squared_size_x + (centered_y * centered_y) / squared_size_y <= 1.0)
	else:
		assert(false, "FIXME!!!")
