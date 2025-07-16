extends BaseAction
class_name SwordAction


func start_action(target_grid_position:Vector2i,on_action_finished:Callable) -> void:
	super.start_action(target_grid_position, on_action_finished)
	print("start"+ action_name)
	finish_action()


func get_action_grids(unit_grid:Vector2i = unit.grid_position) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	var radius = 1
	
	for i in range(-radius,radius + 1):
		for j in range(-radius,radius + 1):
			if i == 0 and j == 0:
				continue
			var potential_grid : Vector2i = unit_grid + Vector2i(i,j)
			
			if is_obstacle(potential_grid):
				continue
			if is_occupied_by_allay(potential_grid):
				continue
			var gird_path = GridManager.get_nav_grid_path(unit_grid,potential_grid)
			var length = GridManager.get_grid_path_length(gird_path)
			if length <= radius and length > 0 and GridManager.is_grid_walkable(potential_grid):#路线长度于等于最大长度（移动力），且大于0（不是原地），且被标记为可移动的网格
				results.append(potential_grid)
			
	return results
