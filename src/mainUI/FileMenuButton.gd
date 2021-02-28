extends MenuButton

enum {
	QUIT,
}

func _ready() -> void:
	var popup = get_popup()
	popup.add_item("Quit", QUIT)
	popup.set_item_shortcut(QUIT, load("res://shortcuts/Quit_shortcut.tres"))
	popup.connect("id_pressed", self, "_on_item_pressed")

func _on_item_pressed(id: int) -> void:
	if id == QUIT:
		get_tree().quit()
