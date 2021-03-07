extends Reference

class_name HeightMapData

const HEIGHT_IMAGE_FORMAT = Image.FORMAT_L8

var luminance_array: PoolByteArray
var height_array: PoolRealArray
var size: Vector2 = Vector2.ZERO

func copy_from(map: HeightMapData) -> void:
	luminance_array = map.luminance_array
	height_array = map.height_array
	size = map.size

func copy_from_image(image: Image) -> void:
	assert(image.get_format() == HEIGHT_IMAGE_FORMAT, "FIXME!!!")
	luminance_array = image.get_data()
	size = image.get_size()
	var pixel_count = int(size.x * size.y)
	height_array.resize(pixel_count)
	for i in pixel_count:
		height_array[i] = (luminance_array[i] / 255.0)

func get_index(x: int, y: int) -> int:
	return int(y * size.x + x)

func get_value(x: int, y: int) -> float:
	var index = get_index(x, y)
	return height_array[index]

func set_value(x: int, y: int, value: float) -> void:
	var index = get_index(x, y)
	height_array[index] = value
	luminance_array[index] = int(value * 255)

func scaled(scale: float) -> PoolRealArray:
	var result = PoolRealArray()
	var float_count = int(size.x * size.y)
	result.resize(float_count)
	for i in float_count:
		result[i] = height_array[i] * scale
	return result

func create_image() -> Image:
	var image = Image.new()
	fill_image(image)
	return image

func fill_image(image: Image) -> void:
	image.create_from_data(int(size.x), int(size.y), false, HEIGHT_IMAGE_FORMAT, luminance_array)
