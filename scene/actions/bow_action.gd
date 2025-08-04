extends BaseAction
class_name BowAction

@export var bow_scene: PackedScene

func start_action(target_grid_position:Vector2i,on_action_finished:Callable) -> void:
	super.start_action(target_grid_position, on_action_finished)
	
	if target_grid_position.x > unit.grid_position.x:
		unit.animated_sprite_2d.scale = Vector2(1.333,1.333)
	elif target_grid_position.x < unit.grid_position.x:
		unit.animated_sprite_2d.scale = Vector2(-1.333,1.333)
	
	var bow:Bow = bow_scene.instantiate()
	unit.weapon_slot.add_child(bow)
	bow.set_up(finish_action,unit,target_grid_position)


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
	
	if hit_obstacle(unit_grid,grid_position):
		return false
	return true
