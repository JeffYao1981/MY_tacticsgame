extends BaseAction
class_name FireballAction


@export var fireball_scene: PackedScene

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


#在点击了目标之后才会执行的方法，触发来源：PlayerActionManager.try_perform_selected_action()
func start_action(target_grid_position:Vector2i,on_action_finished:Callable) -> void:
	#将正在执行打开，回调函数赋值，清空范围显示，扣除相应的行动点
	super.start_action(target_grid_position, on_action_finished)
	
	#控制角色朝向
	if target_grid_position.x > unit.grid_position.x:
		unit.animated_sprite_2d.scale = Vector2(1.333,1.333)
	elif target_grid_position.x < unit.grid_position.x:
		unit.animated_sprite_2d.scale = Vector2(-1.333,1.333)
	
	#控制生成火球
	var fireball:Projectile = fireball_scene.instantiate()
	get_tree().current_scene.add_child(fireball)
	fireball.global_position = unit.weapon_slot.global_position
	fireball.set_up(finish_action,unit,target_grid_position)
	audio_stream_player.play()
	
#func get_action_grids(unit_grid:Vector2i = unit.grid_position) -> Array[Vector2i]:
	#var results: Array[Vector2i] = []
	#var max_range = 3
	#
	#for i in range(-max_range,max_range+1):
		#for j in range(-max_range,max_range+1):
			#if i == 0 and j==0 :
				#continue
			#var potential_grid : Vector2i = unit_grid + Vector2i(i,j)
			#if is_obstacle(potential_grid):
				#continue
			#if is_occupied_by_allay(potential_grid):
				#continue
			#if hit_obstacle(unit_grid,potential_grid):
				#continue
			#results.append(potential_grid)
	#return results

func get_action_grids(unit_grid: Vector2i = unit.grid_position) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	var max_range = 3
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
			queue.append([next_pos, current_distance + 1])
	
	return results
