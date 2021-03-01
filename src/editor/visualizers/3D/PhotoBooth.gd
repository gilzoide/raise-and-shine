extends Spatial

const planemesh = preload("res://editor/visualizers/3D/PlaneMesh.tres")
const planematerial = preload("res://editor/visualizers/3D/Plane_material.tres")
const project = preload("res://editor/project/ActiveEditorProject.tres")

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
onready var lights = $Lights

func _ready() -> void:
	update_planemesh()
	var _err = project.connect("texture_updated", self, "_on_texture_updated")

func update_planemesh() -> void:
	planemesh.subdivide_width = project.height_image.get_width() * 2
	planemesh.subdivide_depth = project.height_image.get_height() * 2
	planematerial.set_shader_param("TEXTURE_PIXEL_SIZE", Vector2.ONE / project.height_image.get_size())

func _on_texture_updated(type: int, _texture: Texture) -> void:
	if type == HEIGHT_MAP:
		update_planemesh()

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
