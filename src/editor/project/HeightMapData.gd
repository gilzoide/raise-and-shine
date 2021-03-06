extends Reference

class_name HeightMapData

var data: PoolByteArray
var size: Vector2

func update_from_image(image: Image) -> void:
	var r = Image.new()
	r.copy_from(image)
	r.convert(Image.FORMAT_L8)
	data = r.get_data()
	size = image.get_size()

func get_value(x: float, y: float) -> float:
	var byte = data[y * size.x + x]
	return byte / 255.0

func set_value(x: float, y: float, value: float):
	data[y * size.x + x] = int(value * 255)

func scaled(scale: float) -> PoolRealArray:
	var result = PoolRealArray()
	result.resize(data.size())
	var byte_scale = scale / 255.0
	for i in data.size():
		result[i] = data[i] * byte_scale
	return result

func create_image() -> Image:
	var image = Image.new()
	fill_image(image)
	return image

func fill_image(image: Image) -> void:
	image.create_from_data(int(size.x), int(size.y), false, Image.FORMAT_L8, data)
