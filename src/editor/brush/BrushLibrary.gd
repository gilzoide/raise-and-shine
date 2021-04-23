# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

const BrushLibraryItem = preload("res://editor/brush/BrushLibraryItem.gd")
const BrushLibraryItemScene = preload("res://editor/brush/BrushLibraryItem.tscn")
const LIBRARY_CACHE_PATH = "user://brush_library.csv"

export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")
export(Resource) var dispatch_queue = preload("res://mainUI/loading/LoadImage_dispatchqueue.tres")
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")

var _cache_dirty = false
var _item_per_path = {}
onready var _brush_item_container = $ScrollContainer/FixedCellGridContainer
onready var _grayscale_albedo_item = $ScrollContainer/FixedCellGridContainer/GrayscaleAlbedoBrushLibraryItem
onready var _should_track_files = ProjectSettings.get_setting("global/brush_library_track_files")


func _ready() -> void:
	_grayscale_albedo_item.texture = MapTypes.map_textures(MapTypes.Type.ALBEDO_MAP)[0]
	if _should_track_files:
		dispatch_queue.dispatch(self, "_load_cached_paths")


func _load_cached_paths() -> void:
	var file = File.new()
	if file.open(LIBRARY_CACHE_PATH, File.READ) == OK:
		var paths = file.get_csv_line()
		file.close()
		for p in paths:
			dispatch_queue.dispatch(self, "_try_load_path", [p])


func _save_cached_paths_if_needed() -> void:
	if not _cache_dirty:
		_cache_dirty = true
		dispatch_queue.call_deferred("dispatch", self, "_save_cached_paths")


func _save_cached_paths() -> void:
	var file = File.new()
	if file.open(LIBRARY_CACHE_PATH, File.WRITE) == OK:
		file.store_csv_line(PoolStringArray(_item_per_path.keys()))
		file.close()
	_cache_dirty = false


func _try_load_path(path: String) -> void:
	var image = Image.new()
	if image.load(path) == OK:
		_on_image_imported(image, path, false)


func _on_ImportButton_pressed() -> void:
	ImageFileDialog.try_load_image(funcref(self, "_on_image_imported"))


func _on_image_imported(image: Image, path: String, cache_if_needed = true) -> void:
	var brush_item = _item_per_path.get(path)
	if not brush_item:
		brush_item = BrushLibraryItemScene.instance()
		brush_item.texture = ImageTexture.new()
		if _should_track_files:
			brush_item.path = path
		brush_item.title = path.get_file()
		brush_item.pressed = false
		var _err = brush_item.connect("removed", self, "_on_brush_item_removed", [brush_item])
		_item_per_path[path] = brush_item
		_brush_item_container.call_deferred("add_child", brush_item)
	brush_item.texture.create_from_image(image, BrushLibraryItem.HEIGHT_TEXTURE_FLAGS)
	
	if _should_track_files and cache_if_needed:
		_save_cached_paths_if_needed()


func _on_brush_item_removed(item) -> void:
	_item_per_path.erase(item.path)
	if _should_track_files:
		_save_cached_paths_if_needed()
