# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

const revision_scene = preload("res://editor/undo/HistoryRevision.tscn")

export(Resource) var history = preload("res://editor/undo/UndoHistory.tres")
export(ButtonGroup) var button_group = preload("res://editor/undo/HistoryRevision_buttongroup.tres")

onready var revision_container = $RevisionContainer


func _ready() -> void:
	history.connect("revision_added", self, "_on_history_revision_added")
	history.connect("revision_changed", self, "_on_history_revision_changed")


func _on_history_revision_added(revision) -> void:
	for i in range(0, revision_container.get_child_count() - revision.id):
		var child = revision_container.get_child(i)
		revision_container.remove_child(child)
		child.queue_free()
	add_revision(revision, true)


func _on_history_revision_changed(revision) -> void:
	var revision_id = revision.id
	revision_container.get_child(revision_container.get_child_count() - 1 - revision_id).set_current()


func _on_revision_button_pressed(id) -> void:
	history.set_current_revision(id)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		refresh_all()


func refresh_all() -> void:
	for c in revision_container.get_children():
		revision_container.remove_child(c)
		c.queue_free()
	var current = history.current_revision
	for i in history.revision_history.size():
		add_revision(history.revision_history[i], i == current)


func add_revision(revision, is_current: bool) -> void:
	var node = revision_scene.instance()
	revision_container.add_child(node)
	revision_container.move_child(node, 0)
	node.set_revision(revision)
	if is_current:
		var pressed_button = button_group.get_pressed_button()
		if pressed_button:
			pressed_button.pressed = false
		node.set_current()
	node.connect("revision_pressed", self, "_on_revision_button_pressed")
