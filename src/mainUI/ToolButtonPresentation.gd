extends Button

export(Resource) var settings = preload("res://settings/DefaultSettings.tres")

onready var _text = text

func _ready() -> void:
	if not settings.show_tool_button_text:
		text = ""
