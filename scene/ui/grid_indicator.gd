extends Node2D

var mouse_grid_position:Vector2i

func _process(delta: float) -> void:
	var new_mouse_grid_position = GridManager.get_mouse_grid_position()
	if !GridManager.is_valid_grid(new_mouse_grid_position):
		return
	if new_mouse_grid_position != mouse_grid_position:
		mouse_grid_position = new_mouse_grid_position
		global_position = GridManager.get_world_position(mouse_grid_position)
