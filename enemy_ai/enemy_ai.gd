extends Node
class_name EnemyAI


@export var unit:Unit


func think() -> AIActionData:
	# 1. 优先尝试直接攻击
	for action in get_attack_actions():
		var attack_intent := try_generate_attack_intent(action)
		if attack_intent != null:
			return attack_intent#（攻击action的目标）

	# 2. 尝试移动到能攻击的位置
	for action in get_attack_actions():
		var move_intent := try_generate_move_intent(action)
		if move_intent != null:
			return move_intent#（移动action的目标）

	# 3. fallback：靠近最近的玩家
	var chase_intent := try_move_towards_player()
	if chase_intent != null:
		return chase_intent

	return null
	

func get_attack_actions() -> Array[BaseAction]:
	# 默认返回所有非 MoveAction 的动作
	var result: Array[BaseAction] = []
	for action in unit.actions_manager.actions:
		if action != null and not (action is MoveAciton):#MoveAcitonMoveAciton
			result.append(action)
	print("获得的第一个action是",result[0].action_id)
	return result

#可以直接攻击的目标
func try_generate_attack_intent(attack_action: BaseAction) -> AIActionData:
	if attack_action == null:
		return null
	if unit.current_action_points < attack_action.action_point_cost:
		return null
	#在攻击action的范围内，获取所有可被攻击角色
	var targets := get_target_in_grids(attack_action.get_action_grids())
	if targets.is_empty():
		return null
	#随机选择一个可被攻击角色
	var target: Unit = targets.pick_random()
	#返回AIActionData
	return AIActionData.new(unit, attack_action, target.grid_position)

#这是移动之后可以攻击到的目标
func try_generate_move_intent(attack_action: BaseAction) -> AIActionData:
	var move_action: BaseAction = unit.actions_manager.get_action("move_action")
	if move_action == null or unit.current_action_points < move_action.action_point_cost:
		return null

	var best_position: Vector2i
	var max_targets := 0
	print("找出来这些个格子：",move_action.get_action_grids().size())
	print("攻击的action是：",attack_action.action_name)
	print("攻击的范围格子是：",attack_action.get_action_grids(Vector2i(2,12)))
	#遍历所有可移动到的网格
	for grid_position in move_action.get_action_grids():
		print("move_action的格子=",grid_position,unit.grid_position)
		#获取在这个网格所有可攻击的目标
		var targets := get_target_in_grids(attack_action.get_action_grids(grid_position))
		#如果可攻击目标的数量大于最大数量
		if targets.size() > max_targets:
			#改写最大数量为当前数量
			max_targets = targets.size()
			#最好的攻击位置=目前的位置
			best_position = grid_position

	if max_targets == 0:
		return null
	#返回：角色、移动action、最好的移动位置
	return AIActionData.new(unit, move_action, best_position)

# fallback：靠近最近的玩家
func try_move_towards_player() -> AIActionData:
	var move_action: BaseAction = unit.actions_manager.get_action("move_action")
	if move_action == null:
		return null

	var enemies = GameManager.player_units
	if enemies.is_empty():
		return null

	# 找最近的敌人
	var closest_enemy = enemies[0]
	var min_dist = unit.grid_position.distance_to(closest_enemy.grid_position)

	for enemy in enemies:
		var dist = unit.grid_position.distance_to(enemy.grid_position)
		if dist < min_dist:
			closest_enemy = enemy
			min_dist = dist

	# 选择靠近最近敌人的位置
	var best_position: Vector2i = unit.grid_position
	var best_dist = min_dist
	for grid_position in move_action.get_action_grids():
		var dist = grid_position.distance_to(closest_enemy.grid_position)
		if dist < best_dist:
			best_dist = dist
			best_position = grid_position

	if best_position == unit.grid_position:
		return null

	return AIActionData.new(unit, move_action, best_position)


#func try_preform_move_action(attack_action:BaseAction , ai_acitoin_data:AIActionData) -> bool:#目前判断逻辑是，移动到攻击action范围覆盖最多角色的那个位置
	#if attack_action == null:					#如果传进来的action为空值，则返回否
		#return false
	#var move_action :BaseAction = unit.actions_manager.get_action("move_action")		#获取角色的moveaction
	#if move_action == null  :		#如果为空，则返回否
		#return false
	#if unit.current_action_points < move_action.action_point_cost : #如果这个action需要的行动值小于角色剩余的行动值，则返回否
		#return false
		#
	#var targets_number = 0		#赋值目标变量为0
	#var target_grid_position:Vector2i  #目标网格坐标
	#for grid_position in move_action.get_action_grids():#循环遍历每一个可以移动到的位置（网格坐标）
		#var targets:Array[Unit] = get_target_in_grids(attack_action.get_action_grids(grid_position))		#在每一个位置上，获取action（攻击）范围覆盖的角色
		#if targets.size() > targets_number:		# 如果范围内的角色数量大于目标变量，则目标变量等于范围内的角色数量，且目标网格坐标等于当前可移动到的位置的网格坐标
			#targets_number = targets.size()
			#target_grid_position = grid_position #最终会留下范围内的角色数量最大的那个网格坐标
	#
	#if targets_number == 0 :#如果等于0,证明范围内没有角色，返回否
		#return false
	#
	#ai_acitoin_data.action = move_action
	#ai_acitoin_data.grid_position = target_grid_position
	#return true
	#
	#
#
#func try_perform_attack_action(attack_action:BaseAction,ai_action_data:AIActionData) -> bool:
	#if attack_action == null :
		#return false
	#if unit.current_action_points < attack_action.action_point_cost:
		#return false
	#var targets:Array[Unit] = get_target_in_grids(attack_action.get_action_grids())#获取攻击范围内的UNIT
	#if targets.is_empty():
		#return false
	#var target:Unit = targets.pick_random()#随机选择攻击范围内的unit作为目标
	#ai_action_data.action = attack_action  #将ai_action_data中的action赋值为传进来的ation
	#ai_action_data.grid_position = target.grid_position		#将ai_action_data中的目标位置赋值为随机选择的那个目标的位置
	#return true
		
func get_target_in_grids(grids: Array[Vector2i]) -> Array[Unit]:
	var targets: Array[Unit] = []
	for grid in grids:
		if GridManager.is_grid_occupied(grid):
			var occupant: Unit = GridManager.get_grid_occupied(grid)
			if occupant != null and not occupant.is_enemy:
				targets.append(occupant)
	return targets	
	
#func get_target_in_grids(grids:Array[Vector2i]) -> Array[Unit]:
	#var targets:Array[Unit] = []
	#for grid in grids:
		#if GridManager.is_grid_occupied(grid) and not GridManager.get_grid_occupied(grid).is_enemy:
			#targets.append(GridManager.get_grid_occupied(grid))
	#return targets
