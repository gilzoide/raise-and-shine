tool
extends Control

export(MapTypes.Type) var type
export(Texture) var texture: Texture = null setget set_texture, get_texture

onready var title_label: Label = $Title
onready var texture_rect = $TextureRect

func _ready() -> void:
	title_label.text = MapTypes.map_name(type)

func set_texture(value: Texture) -> void:
	if texture_rect:
		texture_rect.texture = value

func get_texture() -> Texture:
	return texture_rect.texture
