extends Camera2D

export(NodePath) var sprite_path: NodePath
onready var sprite: Sprite = get_node(sprite_path)
var dragging = false
var pan_modifier = false

func _ready() -> void:
	var _err = sprite.connect("item_rect_changed", self, "update_limits")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("visualizer_pan_modifier"):
		pan_modifier = true
	elif event.is_action_released("visualizer_pan_modifier"):
		pan_modifier = false
	
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo() \
			and (event.button_index == BUTTON_MIDDLE or pan_modifier and event.button_index == BUTTON_LEFT):
		dragging = true
		update_limits()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventMouseButton and not event.is_pressed():
		dragging = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventMouseMotion and dragging:
		translate(-event.relative)

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func update_limits() -> void:
	var my_rect = get_viewport_rect()
	var half_sprite_size = sprite.get_rect().size * 0.5
	limit_left = -my_rect.size.x + half_sprite_size.x
	limit_right = my_rect.size.x - half_sprite_size.x
	limit_top = -my_rect.size.y + half_sprite_size.y
	limit_bottom = my_rect.size.y - half_sprite_size.y
