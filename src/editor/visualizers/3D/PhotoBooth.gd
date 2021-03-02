extends Spatial

const project = preload("res://editor/project/ActiveEditorProject.tres")
const selection = preload("res://editor/selection/ActiveSelection.tres")
const operation = preload("res://editor/selection/ActiveOperation.tres")
const plane_mesh = preload("res://editor/visualizers/3D/PlaneMesh.tres")
const plane_material = preload("res://editor/visualizers/3D/Plane_material.tres")

enum {
	ALBEDO_MAP,
	HEIGHT_MAP,
	NORMAL_MAP,
}

export(float) var plate_angular_speed = 0.01

var background_visible: bool setget set_background_visible, get_background_visible
var lights_enabled: bool setget set_lights_enabled, get_lights_enabled
onready var plate = $Plate
onready var background = $Plate/Background
onready var heightmapshape_collision = $Plate/HeightMapShape
onready var lights = $Lights
onready var plane_size = plane_mesh.size

func _ready() -> void:
	update_plane_dimensions()
	var _err = project.connect("texture_updated", self, "_on_texture_updated")

func update_plane_dimensions() -> void:
	var height_map = project.height_image
	var size = height_map.get_size()
	plane_mesh.subdivide_width = size.x * 2
	plane_mesh.subdivide_depth = size.y * 2
	var plane_heightmapshape = heightmapshape_collision.shape
	plane_heightmapshape.map_width = size.x
	plane_heightmapshape.map_depth = size.y
	heightmapshape_collision.scale.x = plane_size.x / size.x
	heightmapshape_collision.scale.z = plane_size.y / size.y

	var height_scale = min(plane_size.x, plane_size.y) * 0.5
	height_map.lock()
	for y in size.y:
		for x in size.x:
			plane_heightmapshape.map_data[y * size.x + x] = height_map.get_pixel(x, y).r * height_scale
	heightmapshape_collision.shape.map_data = plane_heightmapshape.map_data
	height_map.unlock()
	plane_material.set_shader_param("height_scale", height_scale)
	plane_material.set_shader_param("TEXTURE_PIXEL_SIZE", Vector2.ONE / size)

func _on_texture_updated(type: int, _texture: Texture) -> void:
	if type == HEIGHT_MAP:
		update_plane_dimensions()

func set_background_visible(value: bool) -> void:
	background.visible = value

func get_background_visible() -> bool:
	return background.visible

func rotate_plate_mouse(amount: Vector2) -> void:
	rotate_plate(amount, 0)

func rotate_plate(amount: Vector2, clockwise: float) -> void:
	plate.rotate_y(amount.x * plate_angular_speed)
	plate.rotate_x(amount.y * plate_angular_speed)
	plate.rotate_z(-clockwise * plate_angular_speed)

func set_lights_enabled(value: bool) -> void:
	for c in lights.get_children():
		c.visible = value

func get_lights_enabled() -> bool:
	return lights.get_child(0).visible

func _on_Plate_input_event(_camera: Node, event: InputEvent, click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseMotion:
		var local_click_position = plate.to_local(click_position)
		var uv = Vector2(local_click_position.x, local_click_position.z) / plane_size + Vector2(0.5, 0.5)
		selection.set_mouse_hovering_uv(uv)
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed() and not event.is_echo():
		project.apply_operation_to(operation, selection)

func _on_Plate_mouse_exited() -> void:
	selection.mouse_exited_hovering()
