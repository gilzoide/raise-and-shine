extends TextureRect

signal position_hovered(position)
signal mouse_exited_texture()

const INVALID_POSITION = Vector2(-1, -1)

class ScaledRect:
	var rect: Rect2
	var scale: float
	
	func _init(_rect: Rect2, _scale: float):
		rect = _rect
		scale = _scale

var last_position: Vector2 = INVALID_POSITION
var drawn_rect: ScaledRect

func _ready() -> void:
	update_drawn_rect()

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		emit_signal("mouse_exited_texture")
	elif what == NOTIFICATION_RESIZED:
		update_drawn_rect()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if drawn_rect.rect.has_point(event.position):
			last_position = ((event.position - drawn_rect.rect.position) / drawn_rect.scale).floor()
			emit_signal("position_hovered", last_position)
		else:
			if not last_position.is_equal_approx(INVALID_POSITION):
				emit_signal("mouse_exited_texture")
			last_position = INVALID_POSITION

func update_drawn_rect() -> void:
	# Adapted from TextureRect draw code to include `scale` result
	# Ref: https://github.com/godotengine/godot/blob/7961a1dea3e7ce8c4e7197a0000e35ab31e9ff2e/scene/gui/texture_rect.cpp#L66-L81
	var texture_size = texture.get_size()
	var size = rect_size
	var scale = size.y / texture_size.y
	var tex_width = texture_size.x * scale
	var tex_height = size.y

	if tex_width > size.x:
		tex_width = size.x
		scale = tex_width / texture_size.x
		tex_height = texture_size.y * scale
	
	var offset = Vector2((size.x - tex_width) * 0.5, (size.y - tex_height) * 0.5)
	var rect = Rect2(offset.x, offset.y, tex_width, tex_height)
	drawn_rect = ScaledRect.new(rect, scale)
