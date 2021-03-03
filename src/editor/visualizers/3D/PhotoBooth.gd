extends Spatial

signal drag_started()
signal drag_ended()

const project = preload("res://editor/project/ActiveEditorProject.tres")
const selection = preload("res://editor/selection/ActiveSelection.tres")
const operation = preload("res://editor/selection/DragOperation.tres")
const plane_mesh = preload("res://editor/visualizers/3D/PlaneMesh.tres")
const plane_material = preload("res://editor/visualizers/3D/Plane_material.tres")

enum {
	ALBEDO_MAP,
	HEIGHT_MAP,
	NORMAL_MAP,
}

export(float) var plate_angular_speed = 0.01
export(float) var drag_height_speed = 0.01

var alpha_enabled: bool setget set_alpha_enabled, get_alpha_enabled
var lights_enabled: bool setget set_lights_enabled, get_lights_enabled
onready var plate = $Plate
onready var heightmapshape_collision = $Plate/HeightMapShape
onready var lights = $Lights
onready var ambient_light = $WorldEnvironment
onready var plane_size = plane_mesh.size
var dragging = false

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

func set_alpha_enabled(value: bool) -> void:
	plane_material.set_shader_param("use_alpha", value)

func get_alpha_enabled() -> bool:
	return plane_material.get_shader_param("use_alpha")

func rotate_plate_mouse(amount: Vector2) -> void:
	rotate_plate(amount, 0)

func rotate_plate(amount: Vector2, clockwise: float) -> void:
	plate.rotate_y(amount.x * plate_angular_speed)
	plate.rotate_x(amount.y * plate_angular_speed)
	plate.rotate_z(-clockwise * plate_angular_speed)

func get_light_nodes() -> Array:
	return lights.get_children()

func set_lights_enabled(value: bool) -> void:
	for c in lights.get_children():
		c.visible = value

func get_lights_enabled() -> bool:
	return lights.get_child(0).visible

func _on_Plate_input_event(_camera: Node, event: InputEvent, click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.is_echo():
		if event.is_pressed():
			start_dragging()
		else:
			stop_dragging()
	elif event is InputEventMouseMotion:
		if dragging and not selection.empty():
			operation.amount = -event.relative.y * drag_height_speed
			project.apply_operation_to(operation, selection)
		else:
			var local_click_position = plate.to_local(click_position)
			var uv = Vector2(local_click_position.x, local_click_position.z) / plane_size + Vector2(0.5, 0.5)
			selection.set_mouse_hovering_uv(uv)

func start_dragging() -> void:
	dragging = true
	emit_signal("drag_started")

func stop_dragging() -> void:
	dragging = false
	emit_signal("drag_ended")

func _on_Plate_mouse_exited() -> void:
	stop_dragging()
	selection.mouse_exited_hovering()
