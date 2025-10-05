extends Node

# 执行一次回合（异步回调）
# is_red: true => 红方回合；false => 黑方回合
# on_finished: Callable() 回调
func perform_ai_turn(is_red: bool, on_finished: Callable) -> void:
	# 直接使用全局的 GameManager 实例
	if not is_instance_valid(GameManager):
		push_error("GameManager 未找到或无效")
		on_finished.call()
		return
	
	# 根据阵营获取对应的棋子数组
	var units: Array
	if is_red:
		units = GameManager.chess_piece_red
	else:
		units = GameManager.chess_piece_black
	
	# 如果没有可用的棋子，直接结束回合
	if units.is_empty():
		print("AI回合：无可用棋子")
		on_finished.call()
		return
	
	# 收集所有可行动作（每个棋子可能多个目标格）
	var candidates: Array = []
	
	for unit in units:
		# 检查单位实例是否有效
		if not is_instance_valid(unit):
			continue
		
		# 检查单位是否有行动管理器
		
		
		# 获取单位的行动列表
		var actions = unit.actions_manager.actions
		
			
		
		# 遍历每个行动，收集可用的目标格子
		for action in actions:
			
			
			# 使用 get_action_grids() 来获取可选格子
			
			var grids: Array = action.get_action_grids()
			if grids and not grids.is_empty():
				var entry: Dictionary = {
					"unit": unit,
					"action": action,
					"grids": grids
					}
				candidates.append(entry)
	
	# 如果没有可用的行动，结束回合
	if candidates.is_empty():
		print("AI回合：无可用行动")
		on_finished.call()
		return
	
	# 随机挑选一个候选行动
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var idx: int = rng.randi_range(0, candidates.size() - 1)
	var pick: Dictionary = candidates[idx]
	
	var unit: Unit = pick.get("unit")
	var action: BaseAction = pick.get("action")
	var grids: Array = pick.get("grids", [])
	
	if grids.is_empty():
		on_finished.call()
		return
	
	# 随机选择一个目标格子
	var target_idx: int = rng.randi_range(0, grids.size() - 1)
	var target_grid: Vector2i = grids[target_idx]
	
	print("AI执行行动：", unit.unit_name, " 使用 ", action.action_name, " 目标：", target_grid)
	
	# 执行行动
	action.start_action(target_grid, func():
		on_finished.call()
	)
