extends WindowDialog

export(Resource) var settings = preload("res://settings/DefaultSettings.tres")

onready var show_on_startup_checkbox: CheckBox = $VBoxContainer/ShowOnStartCheckBox


func _ready() -> void:
	show_on_startup_checkbox.visible = settings.can_save()
	show_on_startup_checkbox.pressed = not settings.skip_onboarding_at_startup


func _on_ShowOnStartCheckBox_toggled(button_pressed: bool) -> void:
	settings.set_skip_onboarding_at_startup(not button_pressed)
