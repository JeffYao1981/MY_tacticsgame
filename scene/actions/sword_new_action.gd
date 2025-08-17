extends BaseAction
class_name Sword_new_action


@export var slash_effect: PackedScene
var target_position:Vector2i

func start_action(target_grid_position:Vector2i,on_action_finished:Callable) -> void:
	target_position = target_grid_position
	super.start_action(target_position, on_action_finished)
	
	if target_position.x > unit.grid_position.x:
		unit.sprite_2d.scale = Vector2(1,1)
		
	elif target_position.x < unit.grid_position.x:
		unit.sprite_2d.scale = Vector2(-1,1)
		
	unit.animation_player.play("sword_attack_side")
	
	
	
	
func attack_animation_contor() -> void:
	unit.animation_player.play("idle")


func set_effect() -> void:
	var slash:SwordSlash = slash_effect.instantiate()
	add_child(slash)
	slash.position = GridManager.get_world_position(target_position)   
	slash.set_up(finish_action,unit,target_position)

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
