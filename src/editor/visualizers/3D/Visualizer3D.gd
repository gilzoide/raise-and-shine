extends Spatial

const planemesh = preload("res://editor/visualizers/3D/PlaneMesh.tres")
const project = preload("res://editor/project/ActiveEditorProject.tres")

enum {
	ALBEDO_MAP,
	HEIGHT_MAP,
	NORMAL_MAP,
}

export(float) var plate_angular_speed = 0.01

var perspective: bool setget set_perspective, get_perspective
var background_visible: bool setget set_background_visible, get_background_visible
onready var camera = $Camera
onready var plate = $Plate
onready var background = $Plate/Background

func _ready() -> void:
	update_planemesh()
	project.connect("texture_updated", self, "_on_texture_updated")

func update_planemesh() -> void:
	planemesh.subdivide_width = project.height_image.get_width()
	planemesh.subdivide_depth = project.height_image.get_height()

func _on_texture_updated(type: int, texture: Texture) -> void:
	if type == HEIGHT_MAP:
		update_planemesh()

func set_perspective(value: bool) -> void:
	camera.projection = Camera.PROJECTION_PERSPECTIVE if value else Camera.PROJECTION_ORTHOGONAL

func get_perspective() -> bool:
	return camera.projection == Camera.PROJECTION_PERSPECTIVE

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
