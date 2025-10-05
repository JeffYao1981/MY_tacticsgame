extends Node
class_name EnemyAI

@export var unit: Unit  # 这里 unit 是你的 Unit 节点引用（你已有）

func think() -> AIActionData:
	print("🤖", unit.unit_name, "开始思考")

	# 1. 优先尝试直接攻击
	for action in get_attack_actions():
		var attack_intent := try_generate_attack_intent(action)
		if attack_intent != null:
			return attack_intent

	# 2. 尝试移动到能攻击的位置（仅返回 move 意图，实际执行由 EnemyActionManage 负责）
	for action in get_attack_actions():
		var move_intent := try_generate_move_intent(action)
		if move_intent != null:
			return move_intent

	# 没有任何意图
	return null


func get_attack_actions() -> Array:
	# 子类应重写并返回该 unit 的攻击动作数组，例如 [unit.actions_manager.get_action("bow_action")]
	return []


func try_generate_attack_intent(attack_action: BaseAction) -> AIActionData:
	if attack_action == null:
		return null
	# 检查真实 AP（这里仅判断，不消耗真实 AP；消耗在 EnemyActionManage 的虚拟 AP 中处理）
	if unit.current_action_points < attack_action.action_point_cost:
		return null

	# 获取 attack_action 在 unit.grid_position 的覆盖格子（注意某些 action 可能支持带参数的 get_action_grids）
	var grids :Array[Vector2i]= attack_action.get_action_grids(unit.grid_position) if attack_action.has_method("get_action_grids") else []
	if grids.is_empty():
		return null

	# 在这些格子里找玩家单位（使用全局 GridManager 提供的方法）
	for grid in grids:
		if GridManager.is_grid_occupied(grid):  # GridManager: 判断格子是否被占
			var occupant := GridManager.get_grid_occupied(grid)  # GridManager: 返回占据该格的 unit
			if occupant != null and not occupant.is_enemy:
				return AIActionData.new(unit, attack_action, grid, AIActionData.IntentType.ATTACK)

	return null


func try_generate_move_intent(attack_action: BaseAction) -> AIActionData:
	# 尝试找到一个移动位置，使得从该位置能攻击到最多玩家
	var move_action: BaseAction = unit.actions_manager.get_action("move_action")
	if move_action == null:
		return null
	# 检查真实 AP
	if unit.current_action_points < move_action.action_point_cost:
		return null

	var best_position: Vector2i = unit.grid_position
	var max_targets: int = 0
	for candidate_position in move_action.get_action_grids():
		var targets := get_target_in_positions(attack_action.get_action_grids(candidate_position))
		if targets.size() > max_targets:
			max_targets = targets.size()
			best_position = candidate_position

	if max_targets == 0:
		return null

	return AIActionData.new(unit, move_action, best_position, AIActionData.IntentType.MOVE)


func get_target_in_positions(positions: Array) -> Array:
	var results: Array = []
	for position in positions:
		if GridManager.is_grid_occupied(position):
			var occupant := GridManager.get_grid_occupied(position)
			if occupant != null and not occupant.is_enemy:
				results.append(occupant)
	return results
