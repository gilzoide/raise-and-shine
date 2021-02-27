extends Control

enum {
#	TOGGLE_BACKGROUND,
#	TOGGLE_ALBEDO,
#	TOGGLE_HEIGHT,
	TOGGLE_NORMAL,
}

const sprite_material = preload("res://editor/visualizers/2D/Sprite_material.tres")
onready var flags_menu = $FlagsMenu
onready var flags_menu_popup = flags_menu.get_popup()

func _ready() -> void:
	flags_menu_popup.hide_on_checkable_item_selection = false
#	flags_menu_popup.add_check_item("Background", TOGGLE_BACKGROUND)
#	update_background_check_item()
#	flags_menu_popup.add_check_item("Albedo", TOGGLE_ALBEDO)
#	update_albedo_check_item()
#	flags_menu_popup.add_check_item("Height", TOGGLE_HEIGHT)
#	update_height_check_item()
	flags_menu_popup.add_check_item("Normal", TOGGLE_NORMAL)
	update_normal_check_item()
	var _err = flags_menu_popup.connect("id_pressed", self, "_on_menu_popup_id_pressed")

func _on_menu_popup_id_pressed(id: int) -> void:
#	if id == TOGGLE_BACKGROUND:
#		background_mesh.visible = not background_mesh.visible
#		update_background_check_item()
#	elif id == TOGGLE_ALBEDO:
#		sprite_material.set_shader_param("use_albedo", not sprite_material.get_shader_param("use_albedo"))
#		update_albedo_check_item()
#	elif id == TOGGLE_HEIGHT:
#		sprite_material.set_shader_param("use_height", not sprite_material.get_shader_param("use_height"))
#		update_height_check_item()
	if id == TOGGLE_NORMAL:
		sprite_material.set_shader_param("use_normal", not sprite_material.get_shader_param("use_normal"))
		update_normal_check_item()

#func update_background_check_item() -> void:
#	flags_menu_popup.set_item_checked(TOGGLE_BACKGROUND, background_mesh.visible)
#
#func update_albedo_check_item() -> void:
#	flags_menu_popup.set_item_checked(TOGGLE_ALBEDO, sprite_material.get_shader_param("use_albedo"))
#
#func update_height_check_item() -> void:
#	flags_menu_popup.set_item_checked(TOGGLE_HEIGHT, sprite_material.get_shader_param("use_height"))

func update_normal_check_item() -> void:
	flags_menu_popup.set_item_checked(TOGGLE_NORMAL, sprite_material.get_shader_param("use_normal"))
