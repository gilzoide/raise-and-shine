extends MenuButton

export(Resource) var loaded_project = preload("res://Editor/ActiveEditorProject.tres")
export(NodePath) var file_popup_path: NodePath
onready var file_popup: FileDialog = get_node(file_popup_path)

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
		open_file()

func open_file() -> void:
	file_popup.popup_centered()
	file_popup.connect("file_selected", self, "_on_file_selected", [], CONNECT_ONESHOT)

func _on_file_selected(path: String) -> void:
	print("SELECTED ", path)
