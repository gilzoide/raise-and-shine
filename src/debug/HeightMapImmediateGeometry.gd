"""
Put this as child of a CollisionShape with HeightMapShape to show height points
"""

extends ImmediateGeometry

func _process(delta: float) -> void:
	var shape: HeightMapShape = get_parent().shape
	begin(Mesh.PRIMITIVE_POINTS)
	set_color(Color.yellow)
	var half_height = shape.map_depth * 0.5
	var half_width = shape.map_width * 0.5
	for y in shape.map_depth:
		for x in shape.map_width:
			var height = shape.map_data[y * shape.map_width + x]
			add_vertex(Vector3(x - half_width, height, y - half_height))
	end()
