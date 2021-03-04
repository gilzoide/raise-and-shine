extends Reference

class_name HeightMapData

var data: PoolByteArray
var stride: float

func update_from_image(image: Image) -> void:
	var r = Image.new()
	r.copy_from(image)
	r.convert(Image.FORMAT_R8)
	data = r.get_data()
	stride = image.get_width()

func get_value(x: float, y: float) -> float:
	var byte = data[y * stride + x]
	return byte / 255.0

func set_value(x: float, y: float, value: float):
	data[y * stride + x] = int(value * 255)

func scaled(scale: float) -> PoolRealArray:
	var result = PoolRealArray()
	result.resize(data.size())
	var byte_scale = scale / 255.0
	for i in data.size():
		result[i] = data[i] * byte_scale
	return result
