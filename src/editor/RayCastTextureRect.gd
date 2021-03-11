tool
extends Control

signal drag_started(button_index, uv)
signal drag_moved(relative_motion, uv)
signal drag_ended()

const INVALID_UV = Vector2(-1, -1)

export(Resource) var settings = preload("res://settings/DefaultSettings.tres")
export(Texture) var texture: Texture
var drawn_rect: Rect2

func _draw() -> void:
	update_drawn_rect()
	draw_texture_rect(texture, drawn_rect, false)
	draw_rect(drawn_rect, settings.background_color.inverted(), false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		update()
	elif what == NOTIFICATION_MOUSE_EXIT:
		stop_dragging()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT):
		if event.is_pressed():
			start_dragging(event)
		else:
			stop_dragging()
	elif event is InputEventMouseMotion:
		drag_move(event)

func start_dragging(event: InputEventMouseButton) -> void:
	emit_signal("drag_started", event.button_index, position_to_uv(event.position))

func stop_dragging() -> void:
	emit_signal("drag_ended")

func drag_move(event: InputEventMouseMotion) -> void:
	emit_signal("drag_moved", event.relative, position_to_uv(event.position))

func position_to_uv(position: Vector2) -> Vector2:
	return (position - drawn_rect.position) / drawn_rect.size

func update_drawn_rect() -> void:
	# Ref: https://github.com/godotengine/godot/blob/7961a1dea3e7ce8c4e7197a0000e35ab31e9ff2e/scene/gui/texture_rect.cpp#L66-L81
	var texture_size = texture.get_size()
	var size = rect_size
	var tex_width = texture_size.x * size.y / texture_size.y
	var tex_height = size.y

	if tex_width > size.x:
		tex_width = size.x
		tex_height = texture_size.y * tex_width / texture_size.x
	
	var offset = Vector2((size.x - tex_width) * 0.5, (size.y - tex_height) * 0.5)
	drawn_rect = Rect2(offset.x, offset.y, tex_width, tex_height)
