extends BaseAction
class_name NewMoveAciton

var path:Array[Vector2]
var move_speed: float = 100


func start_action(target_gird_position:Vector2i,on_action_finished:Callable) ->void:
	super.start_action(target_gird_position,on_action_finished)
	
	path = GridManager.get_nav_world_path(unit.grid_position,target_gird_position)
	
	GridManager.set_grid_occupied(unit.grid_position,null)
	GridManager.set_grid_walkable(unit.grid_position,true)
	
	GridManager.set_grid_occupied(target_gird_position,unit)
	GridManager.set_grid_walkable(target_gird_position,false)
		
	unit.animation_player.play("run")
	
func move(target_global_position:Vector2,delta: float) -> void:
	if unit.global_position.x > target_global_position.x:
		unit.sprite_2d.scale = Vector2(-1,1)
		print("翻转")
	if unit.global_position.x < target_global_position.x:
		unit.sprite_2d.scale = Vector2(1,1)
	unit.global_position = unit.global_position.move_toward(target_global_position,move_speed*delta)
	
		
func _process(delta: float) -> void:
	if not is_active:
		return
	if path and not path.is_empty():
		move(path[0],delta)
		if unit.global_position == path[0]:
			path.remove_at(0)
			#GridManager.visualize_grids(PlayerActionManager.selected_action.get_action_grids(),PlayerActionManager.selected_action.grid_color)
	else :
		unit.animation_player.play("idle")
		finish_action()
		

func get_action_grids(unit_grid:Vector2i = unit.grid_position) -> Array[Vector2i]:#获取可操作格子
	var results: Array[Vector2i] = []
	var max_length = 3
	#穷举单位所在网格到目标网格的路线，路线长度超过max_length的，剔除，其他的都放进results表格中
	for i in range(-max_length,max_length+1):
		for j in range(-max_length,max_length+1):
			if i == 0 and j == 0:
				continue
			var potential_grid : Vector2i = unit_grid + Vector2i(i,j)#目标格子
			var gird_path = GridManager.get_nav_grid_path(unit_grid,potential_grid)
			var length = GridManager.get_grid_path_length(gird_path)
			if length <= max_length and length > 0 and GridManager.is_grid_walkable(potential_grid):#路线长度于等于最大长度（移动力），且大于0（不是原地），且被标记为可移动的网格
				results.append(potential_grid)
	return results
	
	
	
	
	
	
	
	
	
	
	
	
	
