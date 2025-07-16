extends BaseAction
class_name FireballAction


func start_action(target_grid_position:Vector2i,on_action_finished:Callable) -> void:
	super.start_action(target_grid_position, on_action_finished)
	print("start"+ action_name)
	finish_action()


func get_action_grids(unit_grid:Vector2i = unit.grid_position) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	var max_range = 3
	
	for i in range(-max_range,max_range+1):
		for j in range(-max_range,max_range+1):
			if i == 0 and j==0 :
				continue
			var potential_grid : Vector2i = unit_grid + Vector2i(i,j)
			if is_obstacle(potential_grid):
				continue
			if is_occupied_by_allay(potential_grid):
				continue
			if hit_obstacle(unit_grid,potential_grid):
				continue
			results.append(potential_grid)
	return results
