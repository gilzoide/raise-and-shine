# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

signal revision_changed(image)

const CHANGE_HEIGHT_ACTION_NAME = "Change height"

var undoredo = UndoRedo.new()

var height_history = []
var current_height = -1


func _init() -> void:
	undoredo.connect("version_changed", self, "_on_version_changed")


func _on_version_changed() -> void:
	set_current_revision(current_height)


func push_heightmapdata(data: HeightMapData, is_first: bool = false) -> void:
	var new_data = HeightMapData.new()
	new_data.copy_from(data)
	height_history.resize(current_height + 1)
	height_history.append(new_data)
	if is_first:
		current_height = 0
	else:
		undoredo.create_action(CHANGE_HEIGHT_ACTION_NAME)
		undoredo.add_do_property(self, "current_height", current_height + 1)
		undoredo.add_undo_property(self, "current_height", current_height)
		undoredo.commit_action()


func set_current_revision(id: int) -> void:
	var data = get_revision(id)
	if data != null:
		current_height = id
		emit_signal("revision_changed", data)


func apply_undo() -> void:
	undoredo.undo()


func apply_redo() -> void:
	undoredo.redo()


func can_undo() -> bool:
	return undoredo.has_undo()


func can_redo() -> bool:
	return undoredo.has_redo()


func get_revision(id: int) -> HeightMapData:
	if id >= 0 and id < height_history.size():
		return height_history[id]
	return null


func is_current(id: int) -> bool:
	return id == current_height
