extends TextureRect

signal position_hovered(uv)
signal drag_started()
signal drag_moved(event)
signal drag_ended()
signal mouse_exited_texture()

const INVALID_UV = Vector2(-1, -1)

var last_uv: Vector2 = INVALID_UV
var drawn_rect: Rect2
var dragging = false

func _ready() -> void:
	update_drawn_rect()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		update_drawn_rect()
	elif what == NOTIFICATION_MOUSE_EXIT:
		stop_dragging()
		emit_signal("mouse_exited_texture")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed() and drawn_rect.has_point(event.position):
			start_dragging()
		else:
			stop_dragging()
			hover_over(event.position)
	elif event is InputEventMouseMotion:
		if dragging:
			emit_signal("drag_moved", event)
		else:
			hover_over(event.position)

func start_dragging() -> void:
	dragging = true
	emit_signal("drag_started")

func stop_dragging() -> void:
	dragging = false
	emit_signal("drag_ended")

func hover_over(position: Vector2) -> void:
	if drawn_rect.has_point(position):
		last_uv = ((position - drawn_rect.position) / drawn_rect.size)
		emit_signal("position_hovered", last_uv)
	else:
		if not last_uv.is_equal_approx(INVALID_UV):
			emit_signal("mouse_exited_texture")
		last_uv = INVALID_UV

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
