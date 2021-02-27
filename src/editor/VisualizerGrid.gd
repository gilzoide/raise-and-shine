extends HSplitContainer

onready var maps_container = $MapsContainer
onready var albedo_editor = $MapsContainer/AlbedoMap
onready var height_editor = $MapsContainer/HeightMap
onready var normal_editor = $MapsContainer/NormalMap

onready var visualizers_container = $VisualizersContainer
onready var orthogonal_editor = $VisualizersContainer/Split/OrthogonalVisualizer
onready var perspective_editor = $VisualizersContainer/Split/PerspectiveVisualizer

func collapse_maps_if_needed() -> void:
	maps_container.visible = albedo_editor.visible or height_editor.visible or normal_editor.visible

func set_albedo_visible(value: bool) -> void:
	albedo_editor.visible = value
	collapse_maps_if_needed()

func set_height_visible(value: bool) -> void:
	height_editor.visible = value
	collapse_maps_if_needed()

func set_normal_visible(value: bool) -> void:
	normal_editor.visible = value
	collapse_maps_if_needed()

func collapse_visualizers_if_needed() -> void:
	visualizers_container.visible = orthogonal_editor.visible or perspective_editor.visible

func set_2d_visible(value: bool) -> void:
	orthogonal_editor.visible = value
	collapse_visualizers_if_needed()

func set_3d_visible(value: bool) -> void:
	perspective_editor.visible = value
	collapse_visualizers_if_needed()
