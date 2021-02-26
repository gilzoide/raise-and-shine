extends Node2D

signal zoom_percent_changed(value)

export(Resource) var loaded_project = preload("res://Editor/Project/ActiveEditorProject.tres")
export(float) var min_zoom: float = 1
export(float) var max_zoom: float = 10
export(float) var zoom_step: float = 0.01

var dragging = false
var zoom = 1
onready var zoom_percent = (zoom - min_zoom) / (max_zoom - min_zoom)
onready var camera = $Camera2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE and event.is_pressed():
		dragging = true
	elif event is InputEventMouseButton and not event.is_pressed():
		dragging = false

func reset():
	set_zoom(1)
	camera.position = Vector2.ZERO

func set_zoom_percent(factor: float) -> void:
	factor = clamp(factor, 0, 1)
	if zoom_percent != factor:
		zoom_percent = factor
		zoom = lerp(min_zoom, max_zoom, zoom_percent)
		camera.zoom = Vector2.ONE / zoom
		emit_signal("zoom_percent_changed", zoom_percent)

func set_zoom(value: float) -> void:
	zoom = clamp(value, min_zoom, max_zoom)
	zoom_percent = (zoom - min_zoom) / (max_zoom - min_zoom)
	camera.zoom = Vector2.ONE / zoom
