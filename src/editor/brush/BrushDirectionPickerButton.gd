extends Button

onready var popup: Popup = $PanelPopup

func _on_pressed() -> void:
	var global_rect = get_global_rect()
	var point = Vector2(global_rect.position.x, global_rect.position.y + global_rect.size.y)
	popup.popup(Rect2(point, popup.rect_size))
