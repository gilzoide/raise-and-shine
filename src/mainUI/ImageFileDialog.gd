extends FileDialog

signal image_loaded(image)

const OPEN_FILTERS = [
	"*.bmp ; BMP",
	"*.dds ; DirectDraw Surface",
	"*.exr ; OpenEXR",
	"*.hdr ; Radiance HDR",
	"*.jpg ; JPG",
	"*.jpeg ; JPEG",
	"*.png ; PNG",
	"*.tga ; Truevision Targa",
	"*.webp ; WebP",
]
const SAVE_FILTERS = [
	"*.exr ; OpenEXR",
	"*.png ; PNG",
]

onready var image_load_error = $AcceptDialog3
onready var image_save_error = $AcceptDialog4
var success_method: FuncRef
var image_to_save: Image

func try_load_image(on_success_method: FuncRef) -> void:
	success_method = on_success_method
	mode = MODE_OPEN_FILE
	filters = OPEN_FILTERS
	popup_centered()

func try_save_image(image: Image) -> void:
	image_to_save = image
	mode = MODE_SAVE_FILE
	filters = SAVE_FILTERS
	popup_centered()

func _on_file_selected(path: String) -> void:
	if mode == MODE_OPEN_FILE:
		var img = Image.new()
		if img.load(path) == OK:
			emit_signal("image_loaded", img)
			if success_method:
				success_method.call_func(img)
		else:
			image_load_error.popup_centered()
	elif mode == MODE_SAVE_FILE:
		var res = ERR_FILE_UNRECOGNIZED
		if path.ends_with(".png"):
			res = image_to_save.save_png(path)
		elif path.ends_with(".exr"):
			res = image_to_save.save_exr(path)
		if res != OK:
			image_save_error.popup_centered()


func _on_popup_hide() -> void:
	"""Cleans up callback related variables"""
	success_method = null
	image_to_save = null
