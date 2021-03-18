extends Control

export(Texture) var texture = preload("res://textures/Height_imagetexture.tres")

var subrect: Rect2


func _draw() -> void:
	draw_texture_rect_region(texture, subrect, subrect)
