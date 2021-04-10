# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends MenuButton

enum {
	FILTER_ALBEDO,
	FILTER_HEIGHT,
	FILTER_NORMAL,
	_SEPARATOR_0,
	TOGGLE_ALBEDO,
	TOGGLE_HEIGHT,
	TOGGLE_NORMAL,
	TOGGLE_LIGHTS,
	TOGGLE_ALPHA,
#	TOGGLE_NORMAL_VECTORS,
	_SEPARATOR_1,
	ALBEDO_FROM_ALBEDO,
	ALBEDO_FROM_HEIGHT,
	ALBEDO_FROM_NORMAL,
	_SEPARATOR_2,
	LAYOUT_RESTORE_DEFAULT,
}

export(ShaderMaterial) var plane_material = preload("res://editor/visualizers/3D/Plane_material.tres")
export(ShaderMaterial) var quad_material = preload("res://editor/visualizers/3D/Quad_material.tres")
export(NodePath) var workbench_container_path

onready var menu_popup = get_popup()
onready var _workbench_panel = get_node(workbench_container_path)


func _ready() -> void:
	menu_popup.hide_on_checkable_item_selection = false
	
	menu_popup.add_check_item("Filter albedo map", FILTER_ALBEDO)
	update_filter_map_check_item(FILTER_ALBEDO, MapTypes.Type.ALBEDO_MAP)
	menu_popup.add_check_item("Filter height map", FILTER_HEIGHT)
	update_filter_map_check_item(FILTER_HEIGHT, MapTypes.Type.HEIGHT_MAP)
	menu_popup.add_check_item("Filter normal map", FILTER_NORMAL)
	update_filter_map_check_item(FILTER_NORMAL, MapTypes.Type.NORMAL_MAP)
	
	menu_popup.add_separator()  # _SEPARATOR_0
	
	menu_popup.add_check_item("Enable Albedo", TOGGLE_ALBEDO)
	menu_popup.set_item_shortcut(TOGGLE_ALBEDO, preload("res://shortcuts/TogglePlaneAlbedo_shortcut.tres"))
	update_albedo_check_item()
	menu_popup.add_check_item("Enable Height", TOGGLE_HEIGHT)
	menu_popup.set_item_shortcut(TOGGLE_HEIGHT, preload("res://shortcuts/TogglePlaneHeight_shortcut.tres"))
	update_height_check_item()
	menu_popup.add_check_item("Enable Normal", TOGGLE_NORMAL)
	menu_popup.set_item_shortcut(TOGGLE_NORMAL, preload("res://shortcuts/TogglePlaneNormal_shortcut.tres"))
	update_normal_check_item()
	menu_popup.add_check_item("Enable Lights", TOGGLE_LIGHTS)
	menu_popup.set_item_shortcut(TOGGLE_LIGHTS, preload("res://shortcuts/TogglePlaneLights_shortcut.tres"))
	update_lights_check_item()
	menu_popup.add_check_item("Enable Alpha", TOGGLE_ALPHA)
	menu_popup.set_item_shortcut(TOGGLE_ALPHA, preload("res://shortcuts/TogglePlaneBackground_shortcut.tres"))
	update_background_check_item()
#	menu_popup.add_check_item("Enable Normal Vectors", TOGGLE_NORMAL_VECTORS)
#	menu_popup.set_item_shortcut(TOGGLE_NORMAL_VECTORS, preload("res://shortcuts/TogglePlaneNormalVectors_shortcut.tres"))
#	update_normal_vectors_check_item()
	
	menu_popup.add_separator()  # _SEPARATOR_1
	
	menu_popup.add_radio_check_item("Preview albedo map", ALBEDO_FROM_ALBEDO)
	menu_popup.set_item_shortcut(ALBEDO_FROM_ALBEDO, preload("res://shortcuts/AlbedoFromAlbedo_shortcut.tres"))
	menu_popup.add_radio_check_item("Preview height map", ALBEDO_FROM_HEIGHT)
	menu_popup.set_item_shortcut(ALBEDO_FROM_HEIGHT, preload("res://shortcuts/AlbedoFromHeight_shortcut.tres"))
	menu_popup.add_radio_check_item("Preview normal map", ALBEDO_FROM_NORMAL)
	menu_popup.set_item_shortcut(ALBEDO_FROM_NORMAL, preload("res://shortcuts/AlbedoFromNormal_shortcut.tres"))
	update_albedo_from_check_items()
	
	menu_popup.add_separator()  # _SEPARATOR_2
	menu_popup.add_item("Restore default layout", LAYOUT_RESTORE_DEFAULT)
	
	menu_popup.connect("id_pressed", self, "_on_menu_popup_id_pressed")


func _on_menu_popup_id_pressed(id: int) -> void:
	if id == FILTER_ALBEDO:
		toggle_filter_map(FILTER_ALBEDO, MapTypes.Type.ALBEDO_MAP)
	elif id == FILTER_HEIGHT:
		toggle_filter_map(FILTER_HEIGHT, MapTypes.Type.HEIGHT_MAP)
	elif id == FILTER_NORMAL:
		toggle_filter_map(FILTER_NORMAL, MapTypes.Type.NORMAL_MAP)
	elif id == TOGGLE_ALBEDO:
		var value = not plane_material.get_shader_param("use_albedo")
		plane_material.set_shader_param("use_albedo", value)
		quad_material.set_shader_param("use_albedo", value)
		update_albedo_check_item()
	elif id == TOGGLE_HEIGHT:
		plane_material.set_shader_param("use_height", not plane_material.get_shader_param("use_height"))
		# quad_material never uses height, that's why it exists in the first place
		update_height_check_item()
	elif id == TOGGLE_NORMAL:
		var value = not plane_material.get_shader_param("use_normal")
		plane_material.set_shader_param("use_normal", value)
		quad_material.set_shader_param("use_normal", value)
		update_normal_check_item()
	elif id == TOGGLE_LIGHTS:
		PhotoBooth.lights_enabled = not PhotoBooth.lights_enabled
		update_lights_check_item()
	elif id == TOGGLE_ALPHA:
		var value = not plane_material.get_shader_param("use_alpha")
		plane_material.set_shader_param("use_alpha", value)
		quad_material.set_shader_param("use_alpha", value)
		update_background_check_item()
#	elif id == TOGGLE_NORMAL_VECTORS:
#		PhotoBooth.normal_vectors_enabled = not PhotoBooth.normal_vectors_enabled
#		update_normal_vectors_check_item()
	elif id == ALBEDO_FROM_ALBEDO:
		plane_material.set_shader_param("albedo_source", 0)
		quad_material.set_shader_param("albedo_source", 0)
		update_albedo_from_check_items()
	elif id == ALBEDO_FROM_HEIGHT:
		plane_material.set_shader_param("albedo_source", 1)
		quad_material.set_shader_param("albedo_source", 1)
		update_albedo_from_check_items()
	elif id == ALBEDO_FROM_NORMAL:
		plane_material.set_shader_param("albedo_source", 2)
		quad_material.set_shader_param("albedo_source", 2)
		update_albedo_from_check_items()
	elif id == LAYOUT_RESTORE_DEFAULT:
		var layout = ResourceLoader.load("res://mainUI/DefaultLayout.tres", "", true)
		_workbench_panel.layout = layout.clone()


func toggle_filter_map(id: int, maptype: int) -> void:
	var maps = MapTypes.map_textures(maptype)
	for m in maps:
		m.flags ^= Texture.FLAG_FILTER
	update_filter_map_check_item(id, maptype)


func update_filter_map_check_item(id: int, maptype: int) -> void:
	var maps = MapTypes.map_textures(maptype)
	menu_popup.set_item_checked(id, bool(maps[0].flags & Texture.FLAG_FILTER))


func update_albedo_check_item() -> void:
	menu_popup.set_item_checked(TOGGLE_ALBEDO, plane_material.get_shader_param("use_albedo"))


func update_height_check_item() -> void:
	menu_popup.set_item_checked(TOGGLE_HEIGHT, plane_material.get_shader_param("use_height"))


func update_normal_check_item() -> void:
	menu_popup.set_item_checked(TOGGLE_NORMAL, plane_material.get_shader_param("use_normal"))


func update_lights_check_item() -> void:
	menu_popup.set_item_checked(TOGGLE_LIGHTS, PhotoBooth.lights_enabled)


func update_background_check_item() -> void:
	menu_popup.set_item_checked(TOGGLE_ALPHA, plane_material.get_shader_param("use_alpha"))


#func update_normal_vectors_check_item() -> void:
#	menu_popup.set_item_checked(TOGGLE_NORMAL_VECTORS, PhotoBooth.normal_vectors_enabled)


func update_albedo_from_check_items() -> void:
	var current = plane_material.get_shader_param("albedo_source")
	menu_popup.set_item_checked(ALBEDO_FROM_ALBEDO, current == 0)
	menu_popup.set_item_checked(ALBEDO_FROM_HEIGHT, current == 1)
	menu_popup.set_item_checked(ALBEDO_FROM_NORMAL, current == 2)
