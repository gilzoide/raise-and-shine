# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

signal revision_added(revision)
signal revision_changed(revision)

class Revision:
	extends Reference
	var id: int
	var heightmap = HeightMapData.new()
	var selection = Image.new()

var revision_history = [ Revision.new() ]
var current_revision = 0


func init_heightmap(data: HeightMapData) -> void:
	revision_history[0].heightmap.copy_from(data)


func init_selection(selection: Image) -> void:
	revision_history[0].selection.copy_from(selection)


func push_heightmapdata(heightmap: HeightMapData) -> void:
	push_revision(heightmap, revision_history[max(0, current_revision - 1)].selection)


func push_selection(selection: Image) -> void:
	push_revision(revision_history[max(0, current_revision - 1)].heightmap, selection)


func push_revision(heightmap: HeightMapData, selection: Image) -> void:
	revision_history.resize(current_revision + 1)
	var new_revision = Revision.new()
	new_revision.heightmap.copy_from(heightmap)
	new_revision.selection.copy_from(selection)
	revision_history.append(new_revision)
	current_revision = revision_history.size() - 1
	new_revision.id = current_revision
	emit_signal("revision_added", new_revision)


func set_current_revision(id: int) -> void:
	if id == current_revision:
		return
	var revision = get_revision(id)
	if revision != null:
		assert(revision.id == id, "FIXME!!!")
		current_revision = id
		emit_signal("revision_changed", revision)


func apply_undo() -> void:
	set_current_revision(current_revision - 1)


func apply_redo() -> void:
	set_current_revision(current_revision + 1)


func can_undo() -> bool:
	return current_revision > 0


func can_redo() -> bool:
	return current_revision < revision_history.size() - 1


func get_revision(id: int) -> Revision:
	if id >= 0 and id < revision_history.size():
		return revision_history[id]
	return null


func is_current(id: int) -> bool:
	return id == current_revision
