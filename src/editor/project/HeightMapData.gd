extends Reference

class_name HeightMapData

var data: PoolByteArray
var stride: float

func update_from_image(image: Image) -> void:
	data = image.get_data()
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
	for byte in data:
		result.append(byte * byte_scale)
	return result
