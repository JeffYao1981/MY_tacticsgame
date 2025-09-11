extends Node


# 简单的红/黑棋子登记与自动走子示例
var red_units: Array = [Unit]
var black_units: Array = [Unit]

func register_unit(unit: Unit, is_red: bool) -> void:
	if is_red:
		if not red_units.has(unit):
			red_units.append(unit)
	else:
		if not black_units.has(unit):
			black_units.append(unit)

func unregister_unit(unit: Unit) -> void:
	red_units.erase(unit)
	black_units.erase(unit)

# 执行一次回合（异步回调）
# is_red: true => 红方回合；false => 黑方回合
# on_finished: Callable() 回调
func perform_ai_turn(is_red: bool, on_finished: Callable) -> void:
	#var pieces := is_red ? red_pieces : black_pieces
	var units: Array
	if is_red:
		units = red_units
	else:
		units = black_units
	if units.is_empty():
		on_finished.call()
		return

	# 收集所有可行动作（每个棋子可能多个目标格）
	var candidates :Array = []
	for unit in units:
		if not is_instance_valid(unit):
			continue
		# 假设每棋子在 actions_manager 里有 ChessMoveAction 等
		for action in unit.actions_manager.actions:
			if action == null:
				continue
			# 使用 get_action_grids() 来获取可选格子
			var grids :Array = action.get_action_grids()
			if grids and not grids.is_empty():
				var entry: Dictionary = {
					"unit": unit,
					"action": action,
					"grids": grids
				}
				candidates.append(entry)

	if candidates.is_empty():
		on_finished.call()
		return
		
	# 随机挑选一个候选行动	
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var idx: int = rng.randi_range(0, candidates.size() - 1)
	var pick: Dictionary = candidates[idx]     
				   
				
	var unit: Unit = pick.get("unit")
	var action: BaseAction = pick.get("action")
	var grids: Array = pick.get("grids", [])          # 明确为 Array
	
	if grids.is_empty():
		on_finished.call()
		return
		
	var target_idx: int = rng.randi_range(0, grids.size() - 1)
	var target_grid: Vector2i = grids[target_idx]       # 明确为 Vector2i
	

	action.start_action(target_grid, func ():
		on_finished.call()
	)
