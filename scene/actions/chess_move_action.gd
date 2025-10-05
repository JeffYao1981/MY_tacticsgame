extends BaseAction


class_name ChessMoveAction

# chess_type: "rook"（车） / "cannon"（炮） 等
@export var chess_type: String = "rook"

# 获取可走/可吃的格子（默认使用 action 所属 unit 的位置）
func get_action_grids(unit_grid:Vector2i = unit.grid_position) -> Array[Vector2i]:
	#if unit_grid == null:
		#unit_grid = unit.grid_position

	match chess_type:
		"rook":
			return _get_rook_moves(unit_grid)
		"cannon":
			return _get_cannon_moves(unit_grid)
		_:
			return []

# 车：直线走到碰到阻挡（可吃敌方的第一个阻挡点）
func _get_rook_moves(start_grid: Vector2i) -> Array[Vector2i]:
	var res: Array[Vector2i] = []
	var dirs := [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for d in dirs:
		var pos := start_grid
		while true:
			pos += d
			if not GridManager.is_valid_grid(pos):
				break
			if GridManager.is_grid_occupied(pos):
				# 如果是敌方，可捕获；如果是友方，阻断（不包含）
				var occupant := GridManager.get_grid_occupied(pos)
				if occupant != null and occupant.faction != unit.faction:
					res.append(pos)
				break
			# 空格可以移动
			res.append(pos)
	return res

# 炮：普通移动（空格）与吃子规则：必须隔一个子（跳子）才能吃目标
func _get_cannon_moves(start_grid: Vector2i) -> Array[Vector2i]:
	var res: Array[Vector2i] = []
	var dirs := [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for d in dirs:
		var pos := start_grid
		# 先收集普通的空格可走（非吃子）
		while true:
			pos += d
			if not GridManager.is_valid_grid(pos):
				break
			if GridManager.is_grid_occupied(pos):
				# 停止普通移动到此处（炮不能在有子旁边停下去吃子）
				break
			res.append(pos)

		# 然后寻找“隔一个子吃目标”的位置
		var pos2 := start_grid
		var jumped := false
		while true:
			pos2 += d
			if not GridManager.is_valid_grid(pos2):
				break
			if GridManager.is_grid_occupied(pos2):
				if not jumped:
					# 首个遇到的子变成“跳子”
					jumped = true
					continue
				else:
					# 已经跳过一个子，再遇到的第一个被视为可吃目标（但只吃敌方）
					var occupant := GridManager.get_grid_occupied(pos2)
					if occupant != null and occupant.faction != unit.faction:
						res.append(pos2)
					break
			# if not occupied and not jumped: 继续寻找跳子；如果已经 jumped 且为空，继续前进，直到遇到目标或边界
	# 返回合并结果
	return res

# 重写 start_action，保留 BaseAction 的消耗/回调逻辑，并做移动动画
func start_action(target_grid_position: Vector2i, on_action_finished: Callable,intent:AIActionData = null) -> void:
	# 调用 BaseAction.start_action (注意 GDScript 中调用父类方法)
	super.start_action(target_grid_position, on_action_finished)

	# 记录旧格子
	var old_grid := unit.grid_position
	var target_world := GridManager.get_world_position(target_grid_position)

	# 动画：使用 Tween 平滑移动到目标格
	var distance := unit.global_position.distance_to(target_world)
	var speed := 100 #unit.move_speed if unit.has_method("move_speed") or unit.has_property("move_speed") else 100.0
	var duration := 0.2
	if speed > 0:
		duration = distance / speed

	var tw = create_tween()
	tw.tween_property(unit, "global_position", target_world, duration)
	await tw.finished

	# 更新格子占位（释放旧格、占据目标格）
	if GridManager.is_valid_grid(old_grid):
		GridManager.set_grid_occupied(old_grid, null)
	GridManager.set_grid_occupied(target_grid_position, unit)

	# 调用 finish_action (父类会调用 on_action_finished)
	finish_action()
