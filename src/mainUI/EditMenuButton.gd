extends MenuButton

enum {
	UNDO,
	REDO,
	HISTORY,
	_SEPARATOR_0,
	SELECTION_CLEAR,
	SELECTION_INVERT,
}
const HISTORY_SUBMENU_NAME = "HistoryPopupMenu"

export(Resource) var history = preload("res://editor/undo/UndoHistory.tres")
export(Resource) var selection = preload("res://editor/selection/ActiveSelection.tres")

onready var menu_popup = get_popup()
var history_submenu = PopupMenu.new()

func _ready() -> void:
	history_submenu.name = HISTORY_SUBMENU_NAME
	history_submenu.connect("about_to_show", self, "_on_history_menu_about_to_show")
	history_submenu.connect("id_pressed", self, "_on_history_menu_id_pressed")
	menu_popup.add_child(history_submenu)
	
	menu_popup.add_item("Undo", UNDO)
	menu_popup.set_item_shortcut(UNDO, preload("res://shortcuts/UndoShortcut.tres"))
	menu_popup.add_item("Redo", REDO)
	menu_popup.set_item_shortcut(REDO, preload("res://shortcuts/RedoShortcut.tres"))
	menu_popup.add_submenu_item("History", HISTORY_SUBMENU_NAME, HISTORY)
	menu_popup.add_separator()
	menu_popup.add_item("Clear selection", SELECTION_CLEAR)
	menu_popup.set_item_shortcut(SELECTION_CLEAR, preload("res://shortcuts/SelectionClear_shortcut.tres"))
	menu_popup.add_item("Invert selection", SELECTION_INVERT)
	menu_popup.set_item_shortcut(SELECTION_INVERT, preload("res://shortcuts/SelectionInvert_shortcut.tres"))
	menu_popup.connect("about_to_show", self, "_on_menu_popup_about_to_show")
	menu_popup.connect("id_pressed", self, "_on_menu_popup_id_pressed")

func _on_menu_popup_id_pressed(id: int) -> void:
	if id == UNDO:
		history.apply_undo()
	elif id == REDO:
		history.apply_redo()
	elif id == SELECTION_CLEAR:
		selection.clear()
	elif id == SELECTION_INVERT:
		selection.invert()

func _on_menu_popup_about_to_show() -> void:
	menu_popup.set_item_disabled(UNDO, not history.can_undo())
	menu_popup.set_item_disabled(REDO, not history.can_redo())

func _on_history_menu_about_to_show() -> void:
	history_submenu.clear()
	for i in range(history.list.size()):
		var id = history.list.size() - i - 1
		var img = history.get_revision(id).create_image()
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		var caption = "*" if history.is_current(id) else ""
		history_submenu.add_icon_item(tex, caption, id)

func _on_history_menu_id_pressed(id: int) -> void:
	history.set_current_revision(id)
