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
export(float) var drag_height_speed = 0.01
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")
export(Resource) var selection = preload("res://editor/selection/ActiveSelection.tres")
export(Resource) var drag_operation = preload("res://editor/operation/DragOperation.tres")
export(Resource) var history = preload("res://editor/undo/UndoHistory.tres")

onready var title_menu_button = $Title
onready var menu_popup = title_menu_button.get_popup()
onready var texture_rect = $TextureRect
onready var height_slider = $TextureRect/HeightDragSlider
var dragged_height = false
var hover_uv: Vector2

func _ready() -> void:
	title_menu_button.text = MapTypes.map_name(type)
	texture_rect.texture = MapTypes.map_texture(type)
	project.connect("texture_updated", self, "_on_texture_updated")
	
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

func _on_texture_updated(type_: int, texture: Texture) -> void:
	if type_ == type:
		texture_rect.texture = texture
		texture_rect.update()

func update_filter_check_item() -> void:
	menu_popup.set_item_checked(TOGGLE_FILTER, texture_rect.texture.flags & Texture.FLAG_FILTER)

func _on_TextureRect_position_hovered(uv) -> void:
	hover_uv = uv

func _on_TextureRect_mouse_exited_texture() -> void:
	selection.mouse_exited_hovering()

func _on_TextureRect_drag_started() -> void:
	selection.set_drag_operation_started(hover_uv)
#	height_slider.show_at_position(get_global_mouse_position())
#	height_slider.update_height(selection.get_hover_position_height())
#	mouse_default_cursor_shape = Control.CURSOR_VSIZE

func _on_TextureRect_drag_ended() -> void:
	selection.set_drag_operation_ended()
#	if dragged_height:
#		history.push_heightmapdata(project.height_data)
#	dragged_height = false
#	mouse_default_cursor_shape = Control.CURSOR_ARROW
#	height_slider.hide()

func _on_TextureRect_drag_moved(event, uv) -> void:
	selection.set_drag_hovering(event, uv)
#	dragged_height = true
#	drag_operation.amount = -event.relative.y * drag_height_speed
#	project.apply_operation_to(drag_operation, selection)
#	height_slider.update_height(selection.get_hover_position_height())


func _on_TextureRect_mouse_entered_texture(uv: Vector2) -> void:
	hover_uv = uv
