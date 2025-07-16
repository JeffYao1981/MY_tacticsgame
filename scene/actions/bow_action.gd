extends BaseAction
class_name BowAction


func start_action(target_grid_position:Vector2i,on_action_finished:Callable) -> void:
	super.start_action(target_grid_position, on_action_finished)
	print("start"+ action_name)
	finish_action()


func get_action_grids(unit_grid:Vector2i = unit.grid_position) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	var max_range = 2
	
	for i in range(-max_range,max_range+1):
		if i == 0 :
			continue
		var potential_grid : Vector2i = unit_grid + Vector2i(i,0)
		if is_valid_action_grid(unit_grid,potential_grid):
			results.append(potential_grid)
		potential_grid = unit_grid + Vector2i(0,i)
		if is_valid_action_grid(unit_grid,potential_grid):
			results.append(potential_grid)
	return results
	
func is_valid_action_grid(unit_grid:Vector2i,grid_position: Vector2i) -> bool:
	if is_obstacle(grid_position):
		return false
	if is_occupied_by_allay(grid_position):
		return false
	if hit_obstacle(unit_grid,grid_position):
		return false
	return true
