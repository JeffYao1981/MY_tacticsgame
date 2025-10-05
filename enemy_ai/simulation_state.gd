# SimulationState.gd
# 轻量化的虚拟局面（用于规划阶段预测）
# - 不改变真实游戏数据
# - 保存 unit 的引用（而不是靠 instance id 反查），这样可以直接使用已有全局方法或 unit 自身字段

extends Resource
class_name SimulationState

# unit_id (int) -> Vector2i (grid position)
var position_map: Dictionary = {}    # key: int (unit.get_instance_id()), value: Vector2i

# unit_id (int) -> int (hp)
var hp_map: Dictionary = {}         # key: int, value: int

# unit_id (int) -> Unit (引用)，便于返回真实 unit 对象而不使用 Engine.get_instance_from_id
var id_to_unit: Dictionary = {}     # key: int, value: Unit reference

# 从当前游戏状态复制初始状态
static func new_from_game() -> SimulationState:
	var sim := SimulationState.new()
	# GameManager.player_units / GameManager.enemy_units 假定存在且为数组（你原项目中应该有）
	var all_units := []
	if GameManager.player_units != null:
		all_units += GameManager.player_units
	if GameManager.enemy_units != null:
		all_units += GameManager.enemy_units

	for unit:Unit in all_units:
		if not is_instance_valid(unit):
			continue
		var id = unit.get_instance_id()  # Godot 内置：获取对象唯一 id
		sim.position_map[id] = unit.grid_position
		# 假定 unit 有 current_hp 字段
		var hp_val := 0		
		hp_val = unit.current_hp
		sim.hp_map[id] = hp_val
		sim.id_to_unit[id] = unit
	return sim

# 给定 grid position，返回在模拟里该格子的 unit 的 instance id（或 0）
func get_unit_id_at(position: Vector2i) -> int:
	for id in position_map.keys():
		if position_map[id] == position and hp_map.get(id, 0) > 0:
			return id
	return 0

# 给定 unit instance id，返回模拟里保存的 unit 引用（如果有）
func get_unit_by_id(id: int) -> Node:
	return id_to_unit.get(id, null)

# 返回 unit 在模拟里的位置（Vector2i），不存在则 Vector2i.ZERO
func get_unit_position(id: int) -> Vector2i:
	return position_map.get(id, Vector2i.ZERO)

# 在模拟中应用伤害（不修改真实 unit）
func apply_damage(id: int, dmg: int) -> void:
	if not hp_map.has(id):
		return
	hp_map[id] = max(0, hp_map[id] - dmg)

# 在模拟中移动单位（不修改真实 unit）
func move_unit(id: int, new_position: Vector2i) -> void:
	if not position_map.has(id):
		return
	position_map[id] = new_position

# 模拟击退（直接 move_unit）
func apply_knockback(id: int, new_position: Vector2i) -> void:
	move_unit(id, new_position)
