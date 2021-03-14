extends MenuButton

enum {
	ABOUT,
}

onready var menu_popup = get_popup()
var about_popup: Popup = null


func _ready() -> void:
	menu_popup.add_item("About", ABOUT)
	menu_popup.connect("id_pressed", self, "_on_menu_popup_id_pressed")


func _on_menu_popup_id_pressed(id: int) -> void:
	if id == ABOUT:
		if about_popup == null:
			about_popup = load("res://mainUI/AboutPopup.tscn").instance()
			add_child(about_popup)
		about_popup.popup_centered()
