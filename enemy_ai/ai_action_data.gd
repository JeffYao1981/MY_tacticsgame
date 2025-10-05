# AIActionData.gd
# 表示单条 AI 意图（移动或攻击）
extends Resource
class_name AIActionData

enum IntentType { MOVE = 0, ATTACK = 1 }

# 攻击/行动的执行者
var unit: Unit = null

# 要执行的 Action（MoveAction、BowAction 等）
var action: BaseAction = null

# 锁定的目标格子（绝对坐标，Vector2i）
var grid_position: Vector2i = Vector2i.ZERO

# 意图类型：MOVE 或 ATTACK
var intent_type: int = IntentType.ATTACK

# 计划时攻击者的位置（意图阶段记录）
# 名称里包含 position（符合你的命名规范）
var planned_attacker_position: Vector2i = Vector2i.ZERO

# 相对偏移（target - planned_attacker_position）
var relative_offset: Vector2i = Vector2i.ZERO

# 预测数据（用于可视化）
var predicted_damage: int = 0
var predicted_knockback: Vector2i = Vector2i.ZERO

func _init(_unit: Node = null, _action: Node = null, _grid_position: Vector2i = Vector2i.ZERO, _intent_type: int = IntentType.ATTACK) -> void:
	unit = _unit
	action = _action
	grid_position = _grid_position
	intent_type = _intent_type
	if unit != null:
		planned_attacker_position = unit.grid_position
		relative_offset = grid_position - planned_attacker_position

# 根据当前攻击者位置计算执行时的实际目标格子
func get_exec_target_position() -> Vector2i:
	if unit == null:
		return grid_position
	var current_attacker_position:Vector2i = unit.grid_position
	var delta:Vector2i = current_attacker_position - planned_attacker_position
	return grid_position + delta
