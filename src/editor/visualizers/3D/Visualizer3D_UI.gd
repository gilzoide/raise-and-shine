extends Control

enum {
	TOGGLE_BACKGROUND,
	TOGGLE_ALBEDO,
	TOGGLE_HEIGHT,
	TOGGLE_NORMAL,
	TOGGLE_PERSPECTIVE,
}

const plane_material = preload("res://editor/visualizers/3D/Plane_material.tres")

export(float) var faster_speed: float = 5

onready var flags_menu = $FlagsMenu
onready var flags_menu_popup = flags_menu.get_popup()
onready var background_mesh = $ViewportContainer/Viewport/Visualizer3D/Plate/Background
onready var visualizer3D = $ViewportContainer/Viewport/Visualizer3D
var dragging = false

func _ready() -> void:
	flags_menu_popup.hide_on_checkable_item_selection = false
	flags_menu_popup.add_check_item("Background", TOGGLE_BACKGROUND)
	update_background_check_item()
	flags_menu_popup.add_check_item("Albedo", TOGGLE_ALBEDO)
	update_albedo_check_item()
	flags_menu_popup.add_check_item("Height", TOGGLE_HEIGHT)
	update_height_check_item()
	flags_menu_popup.add_check_item("Normal", TOGGLE_NORMAL)
	update_normal_check_item()
	flags_menu_popup.add_check_item("Perspective", TOGGLE_PERSPECTIVE)
	update_perspective_check_item()
	var _err = flags_menu_popup.connect("id_pressed", self, "_on_menu_popup_id_pressed")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo() \
			and event.button_index == BUTTON_MIDDLE:
		dragging = true
	elif event is InputEventMouseButton and not event.is_pressed():
		dragging = false
	if dragging and event is InputEventMouseMotion:
		visualizer3D.rotate_plate_mouse(event.relative)

func _process(delta: float) -> void:
	if has_focus():
		var speed = faster_speed if Input.is_action_pressed("visualizer_3d_faster") else 1
		var movement = Vector2(
			Input.get_action_strength("visualizer_3d_rotate_left") - Input.get_action_strength("visualizer_3d_rotate_right"),
			Input.get_action_strength("visualizer_3d_rotate_up") - Input.get_action_strength("visualizer_3d_rotate_down")
		)
		var clockwise = Input.get_action_strength("visualizer_3d_rotate_clockwise") - Input.get_action_strength("visualizer_3d_rotate_counterclockwise")
		visualizer3D.rotate_plate(movement * speed, clockwise * speed)

func _on_menu_popup_id_pressed(id: int) -> void:
	if id == TOGGLE_BACKGROUND:
		visualizer3D.background_visible = not visualizer3D.background_visible
		update_background_check_item()
	elif id == TOGGLE_ALBEDO:
		plane_material.set_shader_param("use_albedo", not plane_material.get_shader_param("use_albedo"))
		update_albedo_check_item()
	elif id == TOGGLE_HEIGHT:
		plane_material.set_shader_param("use_height", not plane_material.get_shader_param("use_height"))
		update_height_check_item()
	elif id == TOGGLE_NORMAL:
		plane_material.set_shader_param("use_normal", not plane_material.get_shader_param("use_normal"))
		update_normal_check_item()
	elif id == TOGGLE_PERSPECTIVE:
		visualizer3D.perspective = not visualizer3D.perspective
		update_perspective_check_item()

func update_background_check_item() -> void:
	flags_menu_popup.set_item_checked(TOGGLE_BACKGROUND, visualizer3D.background_visible)

func update_albedo_check_item() -> void:
	flags_menu_popup.set_item_checked(TOGGLE_ALBEDO, plane_material.get_shader_param("use_albedo"))

func update_height_check_item() -> void:
	flags_menu_popup.set_item_checked(TOGGLE_HEIGHT, plane_material.get_shader_param("use_height"))

func update_normal_check_item() -> void:
	flags_menu_popup.set_item_checked(TOGGLE_NORMAL, plane_material.get_shader_param("use_normal"))

func update_perspective_check_item() -> void:
	flags_menu_popup.set_item_checked(TOGGLE_PERSPECTIVE, visualizer3D.perspective)
