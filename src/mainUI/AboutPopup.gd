extends Popup

func _on_RichTextLabel_meta_clicked(meta) -> void:
	var _err = OS.shell_open(meta)
