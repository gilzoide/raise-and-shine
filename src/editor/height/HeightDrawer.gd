# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Viewport

signal brush_drawn(rect)
signal cleared()

enum BlendMode {
	MIX,
	ADD,
	SUBTRACT,
	MULTIPLY,
	MAX,
	MIN,
}

const SHADER_PATHS = PoolStringArray([
	"",  # MIX always use CanvasItemMaterial
	"res://editor/height/HeightOperation_add.shader",
	"res://editor/height/HeightOperation_sub.shader",
	"res://editor/height/HeightOperation_mul.shader",
	"res://editor/height/HeightOperation_max.shader",
	"res://editor/height/HeightOperation_min.shader",
])

const SHADER_ONLY_MODE = PoolIntArray([BlendMode.MAX, BlendMode.MIN])

export(Resource) var history = preload("res://editor/undo/UndoHistory.tres")
export(Resource) var project = preload("res://editor/project/ActiveEditorProject.tres")
export(Resource) var brush = preload("res://editor/brush/ActiveBrush.tres")
export(BlendMode) var blend_mode = BlendMode.MIX

var _canvas_item = VisualServer.canvas_item_create()
var _canvas_item_material = CanvasItemMaterial.new()
var _shader_material = ShaderMaterial.new()
var _shader_cache = []


func _ready() -> void:
	get_texture().flags = Texture.FLAG_FILTER
	
	_shader_cache.resize(BlendMode.size())
	
	_canvas_item = VisualServer.canvas_item_create()
	VisualServer.canvas_item_set_parent(_canvas_item, find_world_2d().canvas)
	
	_on_height_texture_changed(project.height_texture)
	project.connect("height_texture_changed", self, "_on_height_texture_changed")
	clear_all()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		VisualServer.free_rid(_canvas_item)


func draw_brush_centered_uv(brush, uv: Vector2) -> void:
	var position = (uv * size).floor()
	draw_brush_centered(brush, position)


func draw_brush_centered(brush, center: Vector2) -> void:
	var half_size = floor(brush.size * 0.5)
	var transform = Transform2D(deg2rad(brush.angle), center)
	var rect = Rect2(-Vector2(half_size, half_size), Vector2(brush.size, brush.size))
	VisualServer.canvas_item_set_material(_canvas_item, RID(_get_current_material()))
	VisualServer.canvas_item_clear(_canvas_item)
	VisualServer.canvas_item_add_set_transform(_canvas_item, transform)
	BrushDrawer.get_texture().draw_rect(_canvas_item, rect, false)
	render_target_update_mode = Viewport.UPDATE_ONCE
	# NOTE: emiting before drawing actually happens only works
	# because HeightDrawer is declared before in Autoload
	emit_signal("brush_drawn", transform.xform(rect))


func cancel_draw() -> void:
	VisualServer.canvas_item_clear(_canvas_item)


func clear_all(color = Color.black) -> void:
	VisualServer.canvas_item_set_material(_canvas_item, RID())
	VisualServer.canvas_item_clear(_canvas_item)
	VisualServer.canvas_item_add_rect(_canvas_item, Rect2(Vector2.ZERO, size), color)
	render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
	render_target_update_mode = Viewport.UPDATE_ONCE
	# NOTE: emiting before drawing actually happens only works
	# because HeightDrawer is declared before in Autoload
	emit_signal("cleared")


func clear_to_texture(texture: Texture) -> void:
	VisualServer.canvas_item_set_material(_canvas_item, RID())
	VisualServer.canvas_item_clear(_canvas_item)
	texture.draw_rect(_canvas_item, Rect2(Vector2.ZERO, size), false)
	render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
	render_target_update_mode = Viewport.UPDATE_ONCE
	# NOTE: emiting before drawing actually happens only works
	# because HeightDrawer is declared before in Autoload
	emit_signal("cleared")


func take_snapshot() -> void:
	var image = get_texture().get_data()
	project.height_image = image
	history.push_revision(image)


func _on_height_texture_changed(texture: Texture, empty_data = false) -> void:
	var new_size = texture.get_size()
	if not new_size.is_equal_approx(size):
		size = new_size
		brush.uv_snap_to_size = new_size
	if empty_data:
		clear_all()
	else:
		clear_to_texture(texture)


func _get_shader_for_mode(blend_mode: int) -> Shader:
	if not _shader_cache[blend_mode]:
		_shader_cache[blend_mode] = load(SHADER_PATHS[blend_mode])
	return _shader_cache[blend_mode]


func _get_current_material():
	if blend_mode == BlendMode.MIX:
		_canvas_item_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		return _canvas_item_material
	elif OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES3 or blend_mode in SHADER_ONLY_MODE:
		# GLES3 use shaders for clamping HDR values into LDR
		_shader_material.shader = _get_shader_for_mode(blend_mode)
		return _shader_material
	else:
		# GLES2 use CanvasItemMaterial's blend modes
		_canvas_item_material.blend_mode = blend_mode
		return _canvas_item_material
