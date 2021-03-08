extends MultiMeshInstance

export(float) var vector_height: float = 5
var plane_size: Vector2
var height_scale: float

func _ready() -> void:
	var vertices = PoolVector3Array()
	vertices.append(Vector3(0, 0, 0))
	vertices.append(Vector3(0, 0, -vector_height))
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	multimesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)

func update_all(normalmap: Image, heightmap: HeightMapData) -> void:
	var size = normalmap.get_size()
	multimesh.instance_count = int(size.x * size.y)
	update_rect(normalmap, heightmap, Rect2(Vector2.ZERO, size))

func update_rect(normalmap: Image, heightmap: HeightMapData, rect: Rect2) -> void:
	var stride = rect.size.x
	var half_size = rect.size * 0.5
	var origin_scale = plane_size / rect.size
	normalmap.lock()
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var i = y * stride + x
			var normal_rgb = normalmap.get_pixel(x, y)
			var normal = Vector3(normal_rgb.r - 0.5, normal_rgb.g - 0.5, normal_rgb.b * 0.5) * 2
			var origin2d = (Vector2(x, y) - half_size) * origin_scale
			var origin = Vector3(origin2d.x, heightmap.get_value(x, y) * height_scale, origin2d.y)
			var basis = Basis(normal.cross(Vector3.UP).normalized(), -normal.angle_to(Vector3.UP))
			var transform = Transform(basis, origin)
			multimesh.set_instance_transform(i, transform)
			multimesh.set_instance_color(i, normal_rgb)
	normalmap.unlock()
