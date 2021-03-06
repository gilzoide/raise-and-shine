extends Resource

signal revision_changed(image)

export(int) var history_limit = 16
var list = [Image.new()]
var current_revision = 0

func set_heightmapdata(data: HeightMapData) -> void:
	var img = list[-1]
	data.fill_image(img)

func push_heightmapdata(data: HeightMapData) -> void:
	if current_revision < list.size() - 1:
		list.resize(current_revision + 1)
	var image
	if list.size() > history_limit:
		image = list.pop_front()
	else:
		image = Image.new()
	data.fill_image(image)
	list.push_back(image)
	current_revision = list.size() - 1

func set_current_revision(id: int) -> void:
	var img = get_revision(id)
	if img != null:
		current_revision = id
		emit_signal("revision_changed", img)

func apply_undo() -> void:
	set_current_revision(current_revision - 1)

func apply_redo() -> void:
	set_current_revision(current_revision + 1)

func can_undo() -> bool:
	return current_revision >= 1

func can_redo() -> bool:
	return current_revision < list.size() - 1

func get_revision(id: int) -> Image:
	if id >= 0 and id < list.size():
		return list[id]
	return null

func is_current(id: int) -> bool:
	return id == current_revision
