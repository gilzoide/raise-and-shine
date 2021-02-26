extends FileDialog

signal image_loaded(image)

onready var image_load_error = $AcceptDialog3
var success_method: FuncRef

func try_load_image(success_method: FuncRef) -> void:
	self.success_method = success_method

func _on_file_selected(path: String) -> void:
	var img = load(path)
	if img:
		emit_signal("image_loaded", img)
		if success_method:
			success_method.call_func()
	else:
		image_load_error.popup_centered()
		success_method = null
