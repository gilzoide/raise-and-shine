extends MenuButton

enum {
	TOGGLE_VIEW_ALBEDO,
	TOGGLE_VIEW_HEIGHT,
	TOGGLE_VIEW_NORMAL,
	TOGGLE_VIEW_2D,
	TOGGLE_VIEW_3D,
}

export(NodePath) var visualizer_grid_path: NodePath
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
