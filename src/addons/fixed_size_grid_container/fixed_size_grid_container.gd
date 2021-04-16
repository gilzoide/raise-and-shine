tool
extends Container
"""
A simple grid Container with fixed size cells, great for long cell lists inside
a ScrollContainer.
"""

enum Direction {
	HORIZONTAL,
	VERTICAL,
}

export(Direction) var direction = Direction.HORIZONTAL setget set_direction
export(Vector2) var cell_size = Vector2(64, 64) setget set_cell_size
export(float) var spacing = 8 setget set_spacing

var _current_cell_size: Vector2
var _grid_rect: Rect2


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_resort()


func _get_minimum_size() -> Vector2:
	if direction == Direction.HORIZONTAL:
		return Vector2(_current_cell_size.x, _grid_rect.size.y)
	else:
		return Vector2(_grid_rect.size.x, _current_cell_size.y)


func set_cell_size(value: Vector2) -> void:
	if not value.is_equal_approx(cell_size):
		cell_size = value
		queue_sort()


func set_direction(value: int) -> void:
	if value != direction:
		direction = value
		queue_sort()


func set_spacing(value: float) -> void:
	if value != spacing:
		spacing = value
		queue_sort()


func _resort() -> void:
	var initial_cell_size = _current_cell_size
	var initial_grid_rect = _grid_rect
	# recalculate _current_cell_size based on minimum sizes
	_current_cell_size = cell_size
	var managed_children = []
	for c in get_children():
		if not c is Control or not c.visible or c.is_set_as_toplevel():
			continue
		var minsize = c.get_combined_minimum_size()
		_current_cell_size.x = max(_current_cell_size.x, minsize.x)
		_current_cell_size.y = max(_current_cell_size.y, minsize.y)
		managed_children.append(c)
	
	# fit children
	var rect = Rect2(Vector2.ZERO, _current_cell_size)
	_grid_rect = Rect2()
	if direction == Direction.HORIZONTAL:
		for c in managed_children:
			fit_child_in_rect(c, rect)
			_grid_rect = _grid_rect.expand(rect.end)
			rect.position.x += rect.size.x + spacing
			if rect.end.x > rect_size.x:
				rect.position.y += rect.size.y + spacing
				rect.position.x = 0
	else:
		for c in managed_children:
			fit_child_in_rect(c, rect)
			_grid_rect = _grid_rect.expand(rect.end)
			rect.position.y += rect.size.y + spacing
			if rect.end.y > rect_size.y:
				rect.position.x += rect.size.x + spacing
				rect.position.y = 0
	
	if not initial_cell_size.is_equal_approx(_current_cell_size) or not initial_grid_rect.size.is_equal_approx(_grid_rect.size):
		minimum_size_changed()
