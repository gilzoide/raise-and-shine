extends TextureRect

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		var tex: ViewportTexture = texture
