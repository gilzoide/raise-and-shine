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

const OPEN_TEXT = "You can also drop files to this window\n"
const SAVE_TEXT = ""

onready var image_load_error = $AcceptDialog3
onready var image_save_error = $AcceptDialog4
var success_method: FuncRef
var image_to_save: Image
var hovering = false

func _ready() -> void:
	var _err = get_tree().connect("files_dropped", self, "_on_files_dropped")

func try_load_image(on_success_method: FuncRef) -> void:
	success_method = on_success_method
	mode = MODE_OPEN_FILE
	filters = OPEN_FILTERS
	dialog_text = OPEN_TEXT
	popup_centered()

func try_save_image(image: Image) -> void:
	if OS.get_name() != "HTML5":
		image_to_save = image
		mode = MODE_SAVE_FILE
		filters = SAVE_FILTERS
		dialog_text = SAVE_TEXT
		popup_centered()
	else:
		var bytes = image.save_png_to_buffer()
		var base64 = Marshalls.raw_to_base64(bytes)
		var uri = "data:image/png;base64," + base64
		if OS.has_feature("JavaScript"):
			JavaScript.eval("""
				function download(dataurl, filename) {
					var a = document.createElement('a');
					a.href = dataurl;
					a.setAttribute('download', filename);
					a.click();
				}
				download('%s', 'raise_and_shine_generated.png');
			""" % uri)
		elif OS.shell_open(uri) != OK:
			image_save_error.popup_centered()

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



func _on_files_dropped(files: PoolStringArray, _screen: int) -> void:
	if visible:
		for f in files:
			if f.ends_with(".png") or f.ends_with(".exr"):
				_on_file_selected(f)
				hide()
				break

func _notification(what: int) -> void:
	if what == NOTIFICATION_POPUP_HIDE:
		success_method = null
		image_to_save = null
		hovering = false
	elif what == NOTIFICATION_MOUSE_ENTER:
		hovering = true
	elif what == NOTIFICATION_MOUSE_EXIT:
		hovering = false
