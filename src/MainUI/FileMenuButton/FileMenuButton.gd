extends MenuButton

export(Resource) var loaded_project = preload("res://Editor/Project/ActiveEditorProject.tres")

const IMAGE_EXTENSIONS = []

enum {
	OPEN_FILE,
}

func _ready() -> void:
	var popup = get_popup()
	popup.add_item("Open File...", OPEN_FILE)
	popup.set_item_shortcut(OPEN_FILE, load("res://MainUI/FileMenuButton/OpenFileShortcut.tres"))
	popup.connect("id_pressed", self, "_on_item_pressed")

func _on_item_pressed(id: int) -> void:
	if id == OPEN_FILE:
		pass
