extends MenuButton

enum {
	TOGGLE_ALBEDO,
	TOGGLE_HEIGHT,
	TOGGLE_NORMAL,
	TOGGLE_LIGHTS,
	TOGGLE_BACKGROUND,
	_SEPARATOR_2,
	ALBEDO_FROM_ALBEDO,
	ALBEDO_FROM_HEIGHT,
	ALBEDO_FROM_NORMAL,
}

const plane_material = preload("res://editor/visualizers/3D/Plane_material.tres")

onready var flags_menu_popup = get_popup()

func _ready() -> void:
	flags_menu_popup.hide_on_checkable_item_selection = false
		
	flags_menu_popup.add_check_item("Enable Albedo", TOGGLE_ALBEDO)
	flags_menu_popup.set_item_shortcut(TOGGLE_ALBEDO, preload("res://shortcuts/TogglePlaneAlbedo_shortcut.tres"))
	update_albedo_check_item()
	flags_menu_popup.add_check_item("Enable Height", TOGGLE_HEIGHT)
	flags_menu_popup.set_item_shortcut(TOGGLE_HEIGHT, preload("res://shortcuts/TogglePlaneHeight_shortcut.tres"))
	update_height_check_item()
	flags_menu_popup.add_check_item("Enable Normal", TOGGLE_NORMAL)
	flags_menu_popup.set_item_shortcut(TOGGLE_NORMAL, preload("res://shortcuts/TogglePlaneNormal_shortcut.tres"))
	update_normal_check_item()
	flags_menu_popup.add_check_item("Enable Lights", TOGGLE_LIGHTS)
	flags_menu_popup.set_item_shortcut(TOGGLE_LIGHTS, preload("res://shortcuts/TogglePlaneLights_shortcut.tres"))
	update_lights_check_item()
	flags_menu_popup.add_check_item("Enable Background", TOGGLE_BACKGROUND)
	flags_menu_popup.set_item_shortcut(TOGGLE_BACKGROUND, preload("res://shortcuts/TogglePlaneBackground_shortcut.tres"))
	update_background_check_item()
	flags_menu_popup.add_separator()
	
	flags_menu_popup.add_radio_check_item("Preview albedo map", ALBEDO_FROM_ALBEDO)
	flags_menu_popup.set_item_shortcut(ALBEDO_FROM_ALBEDO, preload("res://shortcuts/AlbedoFromAlbedo_shortcut.tres"))
	flags_menu_popup.add_radio_check_item("Preview height map", ALBEDO_FROM_HEIGHT)
	flags_menu_popup.set_item_shortcut(ALBEDO_FROM_HEIGHT, preload("res://shortcuts/AlbedoFromHeight_shortcut.tres"))
	flags_menu_popup.add_radio_check_item("Preview normal map", ALBEDO_FROM_NORMAL)
	flags_menu_popup.set_item_shortcut(ALBEDO_FROM_NORMAL, preload("res://shortcuts/AlbedoFromNormal_shortcut.tres"))
	update_albedo_from_check_items()
	
	var _err = flags_menu_popup.connect("id_pressed", self, "_on_menu_popup_id_pressed")

func _on_menu_popup_id_pressed(id: int) -> void:
	if id == TOGGLE_ALBEDO:
		plane_material.set_shader_param("use_albedo", not plane_material.get_shader_param("use_albedo"))
		update_albedo_check_item()
	elif id == TOGGLE_HEIGHT:
		plane_material.set_shader_param("use_height", not plane_material.get_shader_param("use_height"))
		update_height_check_item()
	elif id == TOGGLE_NORMAL:
		plane_material.set_shader_param("use_normal", not plane_material.get_shader_param("use_normal"))
		update_normal_check_item()
	elif id == TOGGLE_LIGHTS:
		PhotoBooth.lights_enabled = not PhotoBooth.lights_enabled
		update_lights_check_item()
	elif id == TOGGLE_BACKGROUND:
		PhotoBooth.background_visible = not PhotoBooth.background_visible
		update_background_check_item()
	elif id == ALBEDO_FROM_ALBEDO:
		plane_material.set_shader_param("albedo_source", 0)
		update_albedo_from_check_items()
	elif id == ALBEDO_FROM_HEIGHT:
		plane_material.set_shader_param("albedo_source", 1)
		update_albedo_from_check_items()
	elif id == ALBEDO_FROM_NORMAL:
		plane_material.set_shader_param("albedo_source", 2)
		update_albedo_from_check_items()

func update_albedo_check_item() -> void:
	flags_menu_popup.set_item_checked(TOGGLE_ALBEDO, plane_material.get_shader_param("use_albedo"))

func update_height_check_item() -> void:
	flags_menu_popup.set_item_checked(TOGGLE_HEIGHT, plane_material.get_shader_param("use_height"))

func update_normal_check_item() -> void:
	flags_menu_popup.set_item_checked(TOGGLE_NORMAL, plane_material.get_shader_param("use_normal"))

func update_lights_check_item() -> void:
	flags_menu_popup.set_item_checked(TOGGLE_LIGHTS, PhotoBooth.lights_enabled)

func update_background_check_item() -> void:
	flags_menu_popup.set_item_checked(TOGGLE_BACKGROUND, PhotoBooth.background_visible)

func update_albedo_from_check_items() -> void:
	var current = plane_material.get_shader_param("albedo_source")
	flags_menu_popup.set_item_checked(ALBEDO_FROM_ALBEDO, current == 0)
	flags_menu_popup.set_item_checked(ALBEDO_FROM_HEIGHT, current == 1)
	flags_menu_popup.set_item_checked(ALBEDO_FROM_NORMAL, current == 2)
