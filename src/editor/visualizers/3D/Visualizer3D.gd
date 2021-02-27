extends Spatial

const planemesh = preload("res://editor/visualizers/3D/PlaneMesh.tres")
const project = preload("res://editor/project/ActiveEditorProject.tres")

func _ready() -> void:
	update_planemesh()

func update_planemesh() -> void:
	planemesh.subdivide_width = project.height_image.get_width()
	planemesh.subdivide_depth = project.height_image.get_height()
