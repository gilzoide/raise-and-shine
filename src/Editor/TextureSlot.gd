extends Control

enum Type {
	ALBEDO_MAP,
	HEIGHT_MAP,
	NORMAL_MAP,
}

export(Type) var type
export(Resource) var project = preload("res://Editor/Project/ActiveEditorProject.tres")

onready var title_label: Label = $Title
onready var texture_rect = $TextureRect

func _ready() -> void:
	title_label.text = MapTypes.map_name(type)
	texture_rect.texture = MapTypes.map_texture(type)

func _on_LoadButton_pressed() -> void:
	project.load_image_dialog(type)
