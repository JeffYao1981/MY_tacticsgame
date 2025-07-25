extends Node
class_name EnemyAI


@export var unit:Unit


func think() -> AIActionData:
	return null
	

func try_preform_move_action(attack_action:BaseAction , ai_acitoin_data:AIActionData) -> bool:#目前判断逻辑是，移动到攻击action范围覆盖最多角色的那个位置
	if attack_action == null:					#如果传进来的action为空值，则返回否
		return false
	var move_action :BaseAction = unit.actions_manager.get_action("move_action")		#获取角色的moveaction
	if move_action == null  :		#如果为空，则返回否
		return false
	if unit.current_action_points < move_action.action_point_cost : #如果这个action需要的行动值小于角色剩余的行动值，则返回否
		return false
		
	var targets_number = 0		#赋值目标变量为0
	var target_grid_position:Vector2i  #目标网格坐标
	for grid_position in move_action.get_action_grids():#循环遍历每一个可以移动到的位置（网格坐标）
		var targets:Array[Unit] = get_target_in_grids(attack_action.get_action_grids(grid_position))		#在每一个位置上，获取action（攻击）范围覆盖的角色
		if targets.size() > targets_number:		# 如果范围内的角色数量大于目标变量，则目标变量等于范围内的角色数量，且目标网格坐标等于当前可移动到的位置的网格坐标
			targets_number = targets.size()
			target_grid_position = grid_position #最终会留下范围内的角色数量最大的那个网格坐标
	
	if targets_number == 0 :#如果等于0,证明范围内没有角色，返回否
		return false
	
	ai_acitoin_data.action = move_action
	ai_acitoin_data.grid_position = target_grid_position
	return true
	
	

func try_perform_attack_action(attack_action:BaseAction,ai_action_data:AIActionData) -> bool:
	if attack_action == null :
		return false
	if unit.current_action_points < attack_action.action_point_cost:
		return false
	var targets:Array[Unit] = get_target_in_grids(attack_action.get_action_grids())#获取攻击范围内的UNIT
	if targets.is_empty():
		return false
	var target:Unit = targets.pick_random()#随机选择攻击范围内的unit作为目标
	ai_action_data.action = attack_action  #将ai_action_data中的action赋值为传进来的ation
	ai_action_data.grid_position = target.grid_position		#将ai_action_data中的目标位置赋值为随机选择的那个目标的位置
	return true
		
	
	
func get_target_in_grids(grids:Array[Vector2i]) -> Array[Unit]:
	var targets:Array[Unit] = []
	for grid in grids:
		if GridManager.is_grid_occupied(grid) and not GridManager.get_grid_occupied(grid).is_enemy:
			targets.append(GridManager.get_grid_occupied(grid))
	return targets
