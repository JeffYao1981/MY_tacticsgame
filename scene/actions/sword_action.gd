extends BaseAction
class_name SwordAction

@export var sword_scene: PackedScene
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func start_action(target_grid_position:Vector2i,on_action_finished:Callable) -> void:
	super.start_action(target_grid_position, on_action_finished)
	
	if target_grid_position.x > unit.grid_position.x:
		unit.animated_sprite_2d.scale = Vector2(1.333,1.333)
	elif target_grid_position.x < unit.grid_position.x:
		unit.animated_sprite_2d.scale = Vector2(-1.333,1.333)
		
	var sword:Sword = sword_scene.instantiate()
	unit.weapon_slot.add_child(sword)
	sword.set_up(finish_action,unit,target_grid_position)
	
	audio_stream_player.play()
	
#func predict_damage(target: Unit) -> int:
	#return sword_scene.damager_amount# 子类覆盖	

#func get_action_grids(unit_grid:Vector2i = unit.grid_position) -> Array[Vector2i]:
	#var results: Array[Vector2i] = []
	#var radius = 2
	#
	#for i in range(-radius,radius + 1):
		#for j in range(-radius,radius + 1):
			#if i == 0 and j == 0:
				#continue
			#var potential_grid : Vector2i = unit_grid + Vector2i(i,j)
			#
			#if is_obstacle(potential_grid):
				#continue
			#if is_occupied_by_allay(potential_grid):
				#continue
			#var gird_path = GridManager.get_nav_grid_path(unit_grid,potential_grid)
			#var length = GridManager.get_grid_path_length(gird_path)
			#if length <= radius and length > 0 :#and GridManager.is_grid_walkable(potential_grid);路线长度于等于最大长度（移动力），且大于0（不是原地），且被标记为可移动的网格
				#results.append(potential_grid)
			#
	#return results
	
func get_action_grids(unit_grid: Vector2i = unit.grid_position) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	var max_range = 1
	var visited: Dictionary = {}
	var queue: Array = []
	
	# 四个方向：上、下、左、右
	var directions = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	
	# 初始化队列和访问记录
	queue.append([unit_grid, 0])  # [位置, 距离]
	visited[unit_grid] = true
	
	while queue.size() > 0:
		var current_data = queue.pop_front()
		var current_pos = current_data[0]
		var current_distance = current_data[1]
		
		# 如果达到最大范围，跳过扩展
		if current_distance >= max_range:
			continue
		
		# 检查四个方向
		for direction in directions:
			var next_pos = current_pos + direction
			
			# 如果已经访问过，跳过
			if visited.has(next_pos):
				continue
			
			# 检查是否为障碍物
			if is_obstacle(next_pos):
				continue
			
			# 检查是否被友军占据
			if is_occupied_by_allay(next_pos):
				continue
			
			# 检查从当前位置到下一个位置是否有障碍物阻挡
			if hit_obstacle(current_pos, next_pos):
				continue
			
			# 标记为已访问
			visited[next_pos] = true
			
			# 如果不是起始位置，添加到结果中
			if next_pos != unit_grid:
				results.append(next_pos)
			
			# 将下一个位置加入队列继续扩展
			
	
	return results



#子类（比如 SwordAction.gd、BowAction.gd）实现自己的预测逻辑：
#func predict_damage(target: Unit) -> int:
	#return unit.stats.attack - target.stats.defense
