extends Control

enum Type {
	ALBEDO_MAP,
	HEIGHT_MAP,
	NORMAL_MAP,
}

enum {
	TOGGLE_FILTER,
	LOAD_IMAGE,
	SAVE_IMAGE_AS,
}

export(Type) var type
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")

onready var title_menu_button = $Title
onready var menu_popup = title_menu_button.get_popup()
onready var texture_rect = $TextureRect

func _ready() -> void:
	title_menu_button.text = MapTypes.map_name(type)
	texture_rect.texture = MapTypes.map_texture(type)
	menu_popup.add_check_item("Filter texture", TOGGLE_FILTER)
	update_filter_check_item()
	menu_popup.add_separator()
	menu_popup.add_item("Load...", LOAD_IMAGE)
	menu_popup.add_item("Save as...", SAVE_IMAGE_AS)
	menu_popup.hide_on_checkable_item_selection = false
	menu_popup.connect("id_pressed", self, "_on_menu_id_pressed")

func _on_menu_id_pressed(id: int) -> void:
	if id == TOGGLE_FILTER:
		texture_rect.texture.flags ^= Texture.FLAG_FILTER
		update_filter_check_item()
	elif id == LOAD_IMAGE:
		project.load_image_dialog(type)
	elif id == SAVE_IMAGE_AS:
		project.save_image_dialog(type)

func update_filter_check_item() -> void:
	menu_popup.set_item_checked(TOGGLE_FILTER, texture_rect.texture.flags & Texture.FLAG_FILTER)
