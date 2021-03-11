# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

signal revision_changed(image)

export(int) var history_limit = 16
var list = [HeightMapData.new()]
var current_revision = 0


func set_heightmapdata(data: HeightMapData) -> void:
	var last = list[-1]
	last.copy_from(data)


func push_heightmapdata(data: HeightMapData) -> void:
	if current_revision < list.size() - 1:
		list.resize(current_revision + 1)
	var mapdata
	if list.size() > history_limit:
		mapdata = list.pop_front()
	else:
		mapdata = HeightMapData.new()
	mapdata.copy_from(data)
	list.push_back(mapdata)
	current_revision = list.size() - 1


func set_current_revision(id: int) -> void:
	var data = get_revision(id)
	if data != null:
		current_revision = id
		emit_signal("revision_changed", data)


func apply_undo() -> void:
	set_current_revision(current_revision - 1)


func apply_redo() -> void:
	set_current_revision(current_revision + 1)


func can_undo() -> bool:
	return current_revision >= 1


func can_redo() -> bool:
	return current_revision < list.size() - 1


func get_revision(id: int) -> HeightMapData:
	if id >= 0 and id < list.size():
		return list[id]
	return null


func is_current(id: int) -> bool:
	return id == current_revision
