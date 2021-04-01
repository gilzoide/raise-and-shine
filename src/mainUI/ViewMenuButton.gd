# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends MenuButton

enum {
	TOGGLE_VIEW_ALBEDO,
	TOGGLE_VIEW_HEIGHT,
	TOGGLE_VIEW_NORMAL,
	TOGGLE_VIEW_2D,
	TOGGLE_VIEW_3D,
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
}

export(NodePath) var visualizer_grid_path: NodePath
export(ShaderMaterial) var plane_material = preload("res://editor/visualizers/3D/Plane_material.tres")
export(ShaderMaterial) var quad_material = preload("res://editor/visualizers/3D/Quad_material.tres")
onready var visualizer_grid = get_node(visualizer_grid_path)
onready var menu_popup = get_popup()


func _ready() -> void:
	menu_popup.hide_on_checkable_item_selection = false
	menu_popup.add_check_item("Show albedo map", TOGGLE_VIEW_ALBEDO)
	menu_popup.set_item_checked(TOGGLE_VIEW_ALBEDO, true)
	menu_popup.set_item_shortcut(TOGGLE_VIEW_ALBEDO, preload("res://shortcuts/ToggleViewAlbedo_shortcut.tres"))
	
	menu_popup.add_check_item("Show height map", TOGGLE_VIEW_HEIGHT)
	menu_popup.set_item_checked(TOGGLE_VIEW_HEIGHT, true)
	menu_popup.set_item_shortcut(TOGGLE_VIEW_HEIGHT, preload("res://shortcuts/ToggleViewHeight_shortcut.tres"))
	
	menu_popup.add_check_item("Show normal map", TOGGLE_VIEW_NORMAL)
	menu_popup.set_item_checked(TOGGLE_VIEW_NORMAL, true)
	menu_popup.set_item_shortcut(TOGGLE_VIEW_NORMAL, preload("res://shortcuts/ToggleViewNormal_shortcut.tres"))
	
	menu_popup.add_check_item("Show 2D visualizer", TOGGLE_VIEW_2D)
	menu_popup.set_item_checked(TOGGLE_VIEW_2D, true)
	menu_popup.set_item_shortcut(TOGGLE_VIEW_2D, preload("res://shortcuts/ToggleView2D_shortcut.tres"))
	
	menu_popup.add_check_item("Show 3D visualizer", TOGGLE_VIEW_3D)
	menu_popup.set_item_checked(TOGGLE_VIEW_3D, true)
	menu_popup.set_item_shortcut(TOGGLE_VIEW_3D, preload("res://shortcuts/ToggleView3D_shortcut.tres"))
	
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
	
	menu_popup.connect("id_pressed", self, "_on_menu_popup_id_pressed")


func _on_menu_popup_id_pressed(id: int) -> void:
	if id == TOGGLE_VIEW_ALBEDO:
		var is_visible = menu_popup.is_item_checked(TOGGLE_VIEW_ALBEDO)
		visualizer_grid.set_albedo_visible(not is_visible)
		menu_popup.set_item_checked(TOGGLE_VIEW_ALBEDO, not is_visible)
	elif id == TOGGLE_VIEW_HEIGHT:
		var is_visible = menu_popup.is_item_checked(TOGGLE_VIEW_HEIGHT)
		visualizer_grid.set_height_visible(not is_visible)
		menu_popup.set_item_checked(TOGGLE_VIEW_HEIGHT, not is_visible)
	elif id == TOGGLE_VIEW_NORMAL:
		var is_visible = menu_popup.is_item_checked(TOGGLE_VIEW_NORMAL)
		visualizer_grid.set_normal_visible(not is_visible)
		menu_popup.set_item_checked(TOGGLE_VIEW_NORMAL, not is_visible)
	elif id == TOGGLE_VIEW_2D:
		var is_visible = menu_popup.is_item_checked(TOGGLE_VIEW_2D)
		visualizer_grid.set_2d_visible(not is_visible)
		menu_popup.set_item_checked(TOGGLE_VIEW_2D, not is_visible)
	elif id == TOGGLE_VIEW_3D:
		var is_visible = menu_popup.is_item_checked(TOGGLE_VIEW_3D)
		visualizer_grid.set_3d_visible(not is_visible)
		menu_popup.set_item_checked(TOGGLE_VIEW_3D, not is_visible)
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
