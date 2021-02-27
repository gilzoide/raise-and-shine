extends HSplitContainer

onready var maps_container = $MapsContainer
onready var albedo_editor = $MapsContainer/AlbedoMap
onready var height_editor = $MapsContainer/HeightMap
onready var normal_editor = $MapsContainer/NormalMap
onready var _2d_editor = $VisualizersContainer/Visualizer2D_UI

func collapse_if_needed() -> void:
	maps_container.visible = albedo_editor.visible or height_editor.visible or normal_editor.visible

func set_albedo_visible(value: bool) -> void:
	albedo_editor.visible = value
	collapse_if_needed()

func set_height_visible(value: bool) -> void:
	height_editor.visible = value
	collapse_if_needed()

func set_normal_visible(value: bool) -> void:
	normal_editor.visible = value
	collapse_if_needed()
