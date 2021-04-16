tool
extends EditorPlugin

const FixedSizeGridContainer = preload("res://addons/fixed_size_grid_container/fixed_size_grid_container.gd")


func _enter_tree() -> void:
	add_custom_type("FixedSizeGridContainer", "Container", FixedSizeGridContainer, null)


func _exit_tree() -> void:
	remove_custom_type("FixedSizeGridContainer")
