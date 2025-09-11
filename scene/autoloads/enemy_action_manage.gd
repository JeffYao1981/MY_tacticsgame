extends Node

var pending_intents: Array[AIActionData] = []
var is_performing_action: bool = false


# ---------- 阶段 1：收集意图 ----------
func collect_intents() -> void:
	pending_intents.clear()
	
	for enemy: Unit in GameManager.enemy_units:
		if not is_instance_valid(enemy):
			continue

		var enemy_ai: EnemyAI = enemy.get_node_or_null("EnemyAI")
		if enemy_ai == null:
			continue

		var intent: AIActionData = enemy_ai.think()
		if intent != null:
			pending_intents.append(intent)
			# 展示 UI（但不执行）
			EnemyIntentVisualizer.show(intent)

	print("已收集敌方意图: %s" % pending_intents.size())


# ---------- 阶段 2：执行意图 ----------
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
	if intent == null or intent.action == null:
		_execute_next_intent(on_finished)
		return
	
	if not is_instance_valid(intent.unit) :#判断当前执行的单位是否有效or intent.unit.is_stunned or intent.unit.is_dead():
		_execute_next_intent(on_finished)
		return
		
	is_performing_action = true

	intent.action.start_action(intent.grid_position, func ():
		# 按照意图时的 grid_position 执行结算
		_resolve_damage_at_position(intent)

		is_performing_action = false
		_execute_next_intent(on_finished)
	)


# ---------- 伤害结算 ----------
func _resolve_damage_at_position(intent: AIActionData) -> void:
	# 检查目标格子
	var occupant: Unit = null
	if GridManager.is_grid_occupied(intent.grid_position):
		occupant = GridManager.get_grid_occupied(intent.grid_position)

	if occupant == null:
		print("攻击落空：目标格子为空")
		return

	# 对格子里的当前单位结算伤害（无论是不是友军）
	var damage: int = intent.action.predict_damage(occupant)
	occupant.take_damage(damage)
	print("敌人攻击 %s，在格子 %s 造成 %d 点伤害" % [occupant.name, str(intent.grid_position), damage])



# ---------- 兼容旧接口 ----------
func try_perform_ai_action() -> void:
	# 不再在意图阶段执行任何动作，只是保持接口不报错
	collect_intents()


func try_perform_action() -> bool:
	# 改为返回 false，避免和新逻辑冲突
	return false


func try_perform_enemy_action(enemy: Unit) -> bool:
	# 保留兼容接口，但不执行
	return false


func on_action_finished() -> void:
	is_performing_action = false
