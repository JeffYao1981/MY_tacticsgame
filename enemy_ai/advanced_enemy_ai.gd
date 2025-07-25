extends Node
class_name AdvancedEnemyAI

@export var unit: Unit
@export var aggression_level: float = 0.7  # 攻击倾向 (0-1)
@export var self_preservation: float = 0.5  # 自保倾向 (0-1)
@export var tactical_awareness: float = 0.8  # 战术意识 (0-1)

# AI决策权重
const WEIGHTS = {
	"damage_potential": 3.0,     # 伤害潜力
	"survival_chance": 2.5,      # 生存机会
	"position_advantage": 2.0,   # 位置优势
	"threat_elimination": 2.5,   # 威胁消除
	"ally_support": 1.5,         # 友军支援
	"resource_efficiency": 1.0   # 资源效率
}

# 基础think方法，子类应该重写这个方法
func think() -> AIActionData:
	return null

# 智能版本的移动行动尝试
func try_perform_smart_move_action(attack_action: BaseAction, ai_action_data: AIActionData) -> bool:
	if attack_action == null:
		return false
	
	var move_action: BaseAction = unit.actions_manager.get_action("move_action")
	if move_action == null:
		return false
	
	if unit.current_action_points < move_action.action_point_cost:
		return false
	
	var best_score = -999999.0
	var best_position: Vector2i
	var found_valid_move = false
	
	# 评估每个可能的移动位置
	for grid_position in move_action.get_action_grids():
		var score = evaluate_move_position(grid_position, attack_action)
		
		if score > best_score:
			best_score = score
			best_position = grid_position
			found_valid_move = true
	
	if not found_valid_move:
		return false
	
	ai_action_data.action = move_action
	ai_action_data.grid_position = best_position
	return true

# 智能版本的攻击行动尝试
func try_perform_smart_attack_action(attack_action: BaseAction, ai_action_data: AIActionData) -> bool:
	if attack_action == null:
		return false
	
	if unit.current_action_points < attack_action.action_point_cost:
		return false
	
	var targets: Array[Unit] = get_target_in_grids(attack_action.get_action_grids())
	if targets.is_empty():
		return false
	
	# 智能选择目标，而不是随机选择
	var best_target = select_best_target(targets)
	
	ai_action_data.action = attack_action
	ai_action_data.grid_position = best_target.grid_position
	return true

# 评估移动位置的分数
func evaluate_move_position(position: Vector2i, attack_action: BaseAction) -> float:
	var score = 0.0
	
	# 攻击潜力评估
	if attack_action != null:
		var attack_targets = get_target_in_grids(attack_action.get_action_grids(position))
		var attack_potential = 0.0
		for target in attack_targets:
			attack_potential += evaluate_target_value(target)
		score += attack_potential * WEIGHTS["damage_potential"] * aggression_level
	
	# 生存能力评估
	var survival_score = evaluate_survival_at_position(position)
	score += survival_score * WEIGHTS["survival_chance"] * self_preservation
	
	# 位置优势评估
	var position_score = evaluate_position_advantage(position)
	score += position_score * WEIGHTS["position_advantage"] * tactical_awareness
	
	# 友军支援评估
	var support_score = evaluate_ally_support(position)
	score += support_score * WEIGHTS["ally_support"]
	
	return score

# 选择最佳攻击目标
func select_best_target(targets: Array[Unit]) -> Unit:
	var best_target = targets[0]
	var best_score = -999999.0
	
	for target in targets:
		var score = evaluate_target_value(target)
		if score > best_score:
			best_score = score
			best_target = target
	
	return best_target

# 评估目标价值
func evaluate_target_value(target: Unit) -> float:
	var score = 0.0
	
	# 基础伤害潜力
	var damage_potential = estimate_damage_to_target(target)
	score += damage_potential
	
	# 目标威胁等级
	var threat_level = calculate_target_threat(target)
	score += threat_level * WEIGHTS["threat_elimination"]
	
	# 低血量目标奖励（容易击杀）
	var health_ratio = float(target.current_hp) / float(target.max_hp)
	var low_health_bonus = (1.0 - health_ratio) * 50.0
	score += low_health_bonus
	
	# 目标类型优先级（例如：法师 > 弓箭手 > 战士）
	score += get_target_type_priority(target)
	
	return score

# 评估在某位置的生存能力
func evaluate_survival_at_position(position: Vector2i) -> float:
	var score = 0.0
	
	# 计算该位置受到的威胁
	var incoming_threat = calculate_incoming_threat_at_position(position)
	score -= incoming_threat * 2.0  # 威胁越大，分数越低
	
	# 逃脱路线数量
	var escape_routes = count_escape_routes_from_position(position)
	score += escape_routes * 15.0
	
	# 掩护评估（如果有地形系统）
	var cover_value = evaluate_cover_at_position(position)
	score += cover_value * 10.0
	
	return score

# 评估位置优势
func evaluate_position_advantage(position: Vector2i) -> float:
	var score = 0.0
	
	# 高地优势
	var terrain_bonus = get_terrain_advantage(position)
	score += terrain_bonus * 20.0
	
	# 控制关键区域
	var strategic_value = get_strategic_position_value(position)
	score += strategic_value * 15.0
	
	# 距离敌方的距离优势
	var positioning_score = evaluate_positioning_advantage(position)
	score += positioning_score
	
	return score

# 评估友军支援
func evaluate_ally_support(position: Vector2i) -> float:
	var score = 0.0
	var nearby_allies = count_nearby_allies(position, 3)  # 3格范围内的友军
	
	# 友军数量带来的支援价值
	score += nearby_allies * 10.0
	
	# 如果血量较低，更需要友军保护
	var health_ratio = float(unit.current_hp) / float(unit.max_hp)
	if health_ratio < 0.5:
		score += nearby_allies * 20.0 * (1.0 - health_ratio)
	
	return score

# 辅助函数实现
func estimate_damage_to_target(target: Unit) -> float:
	var base_damage = unit.attack_power
	var armor_reduction = target.defense * 0.5
	return max(1.0, base_damage - armor_reduction)

func calculate_target_threat(target: Unit) -> float:
	var threat = 0.0
	
	# 目标的攻击力威胁
	threat += target.attack_power * 1.5
	
	# 目标的特殊能力威胁
	threat += evaluate_target_special_abilities(target)
	
	# 目标的移动威胁
	var mobility_threat = target.movement_range * 2.0
	threat += mobility_threat
	
	return threat

func get_target_type_priority(target: Unit) -> float:
	# 根据目标类型返回优先级分数
	# 这里需要根据你的游戏单位类型来调整
	match target.unit_type:
		"mage":
			return 30.0
		"archer":
			return 25.0
		"healer":
			return 35.0
		"warrior":
			return 15.0
		_:
			return 10.0

func calculate_incoming_threat_at_position(position: Vector2i) -> float:
	var total_threat = 0.0
	var enemy_units = get_all_enemy_units()  # 获取所有敌方单位（玩家单位）
	
	for enemy in enemy_units:
		var distance = get_distance(enemy.grid_position, position)
		if distance <= enemy.attack_range:
			total_threat += enemy.attack_power
		# 即使不在攻击范围内，也要考虑移动后的威胁
		elif distance <= enemy.attack_range + enemy.movement_range:
			total_threat += enemy.attack_power * 0.5
	
	return total_threat

func count_escape_routes_from_position(position: Vector2i) -> int:
	var escape_count = 0
	var directions = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
	
	for direction in directions:
		var escape_pos = position + direction
		if is_position_accessible(escape_pos):
			escape_count += 1
	
	return escape_count

func evaluate_cover_at_position(position: Vector2i) -> float:
	# 如果有地形系统，评估该位置的掩护价值
	# 这里返回基础值，可以根据实际地形系统调整
	return 0.0

func get_terrain_advantage(position: Vector2i) -> float:
	# 地形优势评估，如高地、森林等
	# 这里返回基础值，可以根据实际地形系统调整
	return 0.0

func get_strategic_position_value(position: Vector2i) -> float:
	var value = 0.0
	
	# 地图中心位置更有价值
	var map_size = get_map_size()
	var center = Vector2i(map_size.x / 2, map_size.y / 2)
	var distance_to_center = get_distance(position, center)
	value += max(0, 20 - distance_to_center * 2)
	
	return value

func evaluate_positioning_advantage(position: Vector2i) -> float:
	var score = 0.0
	var enemy_units = get_all_enemy_units()
	
	for enemy in enemy_units:
		var distance = get_distance(position, enemy.grid_position)
		# 理想攻击距离的评估
		if distance >= 2 and distance <= 4:
			score += 5.0  # 不太近也不太远
		elif distance < 2:
			score -= 10.0  # 太近了，危险
	
	return score

func count_nearby_allies(position: Vector2i, radius: int) -> int:
	var ally_count = 0
	var all_units = get_all_allied_units()
	
	for ally in all_units:
		if ally == unit:
			continue
		var distance = get_distance(position, ally.grid_position)
		if distance <= radius:
			ally_count += 1
	
	return ally_count

func evaluate_target_special_abilities(target: Unit) -> float:
	# 评估目标的特殊能力威胁
	# 这里需要根据你的游戏特殊能力系统来实现
	return 5.0

func get_all_enemy_units() -> Array[Unit]:
	# 获取所有敌方单位（对AI来说是玩家单位）
	var enemies: Array[Unit] = []
	# 这里需要实现获取所有玩家单位的逻辑
	return enemies

func get_all_allied_units() -> Array[Unit]:
	# 获取所有友方单位（对AI来说是其他AI单位）
	var allies: Array[Unit] = []
	# 这里需要实现获取所有AI单位的逻辑
	return allies

func get_distance(pos1: Vector2i, pos2: Vector2i) -> int:
	return abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y)

func is_position_accessible(position: Vector2i) -> bool:
	return not GridManager.is_grid_occupied(position) and GridManager.is_grid_walkable(position)

func get_map_size() -> Vector2i:
	return Vector2i(GridManager.map_width, GridManager.map_height)

func get_target_in_grids(grids: Array[Vector2i]) -> Array[Unit]:
	var targets: Array[Unit] = []
	for grid in grids:
		if GridManager.is_grid_occupied(grid):
			var occupant = GridManager.get_grid_occupied(grid)
			if not occupant.is_enemy:  # 非敌方单位（即玩家单位）
				targets.append(occupant)
	return targets

# 原始的简单版本方法，保持向后兼容
func try_preform_move_action(attack_action: BaseAction, ai_action_data: AIActionData) -> bool:
	return try_perform_smart_move_action(attack_action, ai_action_data)

func try_perform_attack_action(attack_action: BaseAction, ai_action_data: AIActionData) -> bool:
	return try_perform_smart_attack_action(attack_action, ai_action_data)
