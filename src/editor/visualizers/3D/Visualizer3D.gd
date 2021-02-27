extends Spatial

const planemesh = preload("res://editor/visualizers/3D/PlaneMesh.tres")
const project = preload("res://editor/project/ActiveEditorProject.tres")

var perspective: bool setget set_perspective, get_perspective
var background_visible: bool setget set_background_visible, get_background_visible
onready var camera = $Camera
onready var background = $Plate/Background

func _ready() -> void:
	update_planemesh()
	project.connect("texture_updated", self, "_on_texture_updated")

func update_planemesh() -> void:
	planemesh.subdivide_width = project.height_image.get_width()
	planemesh.subdivide_depth = project.height_image.get_height()

func _on_texture_updated(type: int, texture: Texture) -> void:
	if type == MapTypes.Type.HEIGHT_MAP:
		update_planemesh()

func set_perspective(value: bool) -> void:
	camera.projection = Camera.PROJECTION_PERSPECTIVE if value else Camera.PROJECTION_ORTHOGONAL

func get_perspective() -> bool:
	return camera.projection == Camera.PROJECTION_PERSPECTIVE

func set_background_visible(value: bool) -> void:
	background.visible = value

func get_background_visible() -> bool:
	return background.visible
