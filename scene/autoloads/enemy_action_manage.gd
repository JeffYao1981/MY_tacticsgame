extends Node

## 敌方行动管理器
## - 收集敌方单位意图
## - 在意图阶段，敌方单位可以真实执行移动
## - 在执行阶段，敌方意图会被逐个执行（攻击伤害结算等）

var pending_intents: Array[AIActionData] = []   ## 待执行的意图队列
var is_performing_action: bool = false


# ==========================
# 意图收集（在敌方意图阶段调用）
# ==========================
func collect_intents() -> void:
	pending_intents.clear()

	for unit in GameManager.enemy_units:
		if not is_instance_valid(unit): ## Godot 内置：检查对象是否仍然有效
			continue

		

		# 创建模拟状态（从当前游戏局面复制）
		var sim: SimulationState = SimulationState.new_from_game()
		var virtual_ap: int = unit.current_action_points ## 虚拟 AP，预测时扣除

		# 获取攻击动作
		var attack_actions: Array = []
		var ai_node:EnemyAI = unit.get_node_or_null("EnemyAI") ## Godot 内置：获取子节点（如果不存在则返回 null）
		if ai_node != null and ai_node.has_method("get_attack_actions"):
			attack_actions = ai_node.get_attack_actions()
		elif unit.actions_manager != null:
			for action in unit.actions_manager.actions:
				if action != null and not (action is MoveAciton):
					attack_actions.append(action)

		# 获取移动动作
		var move_action: BaseAction = unit.actions_manager.get_action("move_action") if unit.actions_manager != null else null

		# 如果什么都没有，跳过
		if attack_actions.is_empty() and move_action == null:
			
			continue

		# 循环规划，直到虚拟 AP 用完
		while virtual_ap > 0:
			var any_progress :bool = false
			var sim_unit_id := unit.get_instance_id()
			var sim_unit_position: Vector2i = sim.get_unit_position(sim_unit_id)

			# ---- 1. 优先尝试攻击 ----
			var found_attack :bool = false
			for attack_action:BaseAction in attack_actions:
				if attack_action == null:
					continue
				# _safe_get_action_grids 会优先尝试以 position 参数调用 get_action_grids(position)
				var atk_grids:Array[Vector2i] = _safe_get_action_grids(attack_action, sim_unit_position)
				for target_gird:Vector2i in atk_grids:
					var target_id :int = sim.get_unit_id_at(target_gird)
					if target_id != 0:
						var target_unit :Unit = sim.get_unit_by_id(target_id)
						if target_unit != null and not target_unit.is_enemy:
							# 生成攻击意图
							var intent := AIActionData.new(unit, attack_action, target_gird, AIActionData.IntentType.ATTACK)
							intent.planned_attacker_position = sim_unit_position
							intent.relative_offset = target_gird - sim_unit_position
							
							intent.predicted_damage = attack_action.predict_damage(target_unit)
							
							

							pending_intents.append(intent)
							EnemyIntentVisualizer.add_intent(intent)

							# 在模拟状态中扣血
							sim.apply_damage(target_id, intent.predicted_damage)

							# 扣虚拟 AP
							var atk_cost: int = attack_action.action_point_cost
							
							if atk_cost <= 0:
								atk_cost = 1
							virtual_ap -= atk_cost

							
							found_attack = true
							any_progress = true
							break
				if found_attack:
					break

			if found_attack:
				continue

			# ---- 2. 尝试移动 ----
			if move_action == null:
				break

			var move_cost: int = move_action.action_point_cost
			
			if move_cost <= 0:
				move_cost = 1

			if virtual_ap < move_cost:
				break

			# 遍历候选移动位置，计算能攻击到的目标数
			var best_position: Vector2i = sim_unit_position
			var candidate_positions: Array = _safe_get_action_grids(move_action, sim_unit_position)
			var best_hits: int = -1
			if candidate_positions.is_empty():
				# 没有移动格，结束
				break
			for candidate_position in candidate_positions:
				var hits: int = 0
				for atk:BaseAction in attack_actions:
					if atk == null:
						continue
					for atk_target in _safe_get_action_grids(atk, candidate_position):
						var target_unit_id := sim.get_unit_id_at(atk_target)
						if target_unit_id != 0:
							var target_unit :Unit = sim.get_unit_by_id(target_unit_id)
							if target_unit != null and not target_unit.is_enemy:
								hits += 1
				if hits > best_hits:
					best_hits = hits
					best_position = candidate_position

			# 如果所有位置都不能攻击，走 fallback
			if best_hits <= 0:
				var fallback_position = _choose_fallback_move_position(unit, sim, candidate_positions)
				if fallback_position != Vector2i.ZERO:
					best_position = fallback_position
				else:
					break

			# 在意图阶段真实执行移动
			
			is_performing_action = true
			
			move_action.start_action(best_position, on_action_finished)#func(): finished = true
			
			while  is_performing_action:
				
				await get_tree().process_frame ## Godot 内置：等待一帧（相当于协程）

			unit.current_action_points -= move_cost
			virtual_ap -= move_cost
			sim.move_unit(unit.get_instance_id(), best_position)
			
			any_progress = true

			if not any_progress:
				break

		


# ==========================
# 意图执行（在执行阶段调用）
# ==========================
func execute_intents(on_finished: Callable) -> void:
	if pending_intents.is_empty():
		on_finished.call()
		return
	_execute_next_intent(on_finished)


func _execute_next_intent(on_finished: Callable) -> void:
	if pending_intents.is_empty():
		on_finished.call()
		return

	var intent: AIActionData = pending_intents.pop_front()
	EnemyIntentVisualizer.on_intent_executing(intent,intent.grid_position)
	
	if not is_instance_valid(intent.unit):
		# 如果意图无效，跳过并执行下一个
		_execute_next_intent(on_finished)
		return
	is_performing_action = true

	intent.action.start_action(intent.grid_position, func ()-> void:
		is_performing_action = false
		_execute_next_intent(on_finished)
		EnemyIntentVisualizer.on_intent_executed(intent)
	)


# ==========================
# 辅助函数
# ==========================
func _safe_get_action_grids(action: BaseAction, from_position: Vector2i) -> Array[Vector2i]:
	if action == null:
		return []
	if action.has_method("get_action_grids"):
		# 注意：这里用 argument_count 来判断是否带参数
		if action.get_method_argument_count("get_action_grids") == 1:
			return action.get_action_grids(from_position)
		else:
			return action.get_action_grids()
	return []


func _choose_fallback_move_position(unit: Unit, sim: SimulationState, move_positions: Array)  -> Vector2i:
	if move_positions.is_empty():
		return Vector2i.ZERO
	var players := GameManager.player_units
	if players.is_empty():
		# 没玩家时随机返回一个位置
		return move_positions[randi() % move_positions.size()]

	# 找到模拟里最近的玩家
	var best_player :Unit= null
	var best_dist := 1e9
	for player_unit in players:
		if not is_instance_valid(player_unit):
			continue
		var d :float = (sim.get_unit_position(unit.get_instance_id()) - player_unit.grid_position).length()
		if d < best_dist:
			best_dist = d
			best_player = player_unit

	# 选择 move_positions 中最靠近 best_player 的格子
	var chosen :Vector2i = move_positions[0]
	var chosen_dist := 1e9
	for p in move_positions:
		var d2:float = (p - best_player.grid_position).length()
		if d2 < chosen_dist:
			chosen_dist = d2
			chosen = p
	return chosen



func on_action_finished() ->void:
	is_performing_action = false
