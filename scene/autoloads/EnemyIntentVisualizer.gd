# EnemyIntentVisualizer.gd
# 聚合并显示敌方意图（支持叠加、多条线、执行高亮）
extends Node2D


# UI 容器：建议在场景 ready 中设置： EnemyIntentVisualizer.action_ui_layer = $Main/UILayer
var action_ui_layer: Node2D 
# key -> { intents: Array[AIActionData], lines: Array[Line2D], label: Label, container: Node2D, exec_node: Node2D }
# key 格式："x,y"
var target_intents: Dictionary = {}

# intent -> key，用于快速删除某条 intent
var intent_to_key: Dictionary = {}
var selected_action:BaseAction
# 配色/参数
const PREVIEW_COLOR := Color(1.0, 0.2, 0.2, 0.7)   # 红色，意图预览
const EXEC_COLOR := Color(0.2, 1.0, 0.2, 0.9)      # 绿色，高亮执行
const PREVIEW_WIDTH := 3.0
const OFFSET_STEP := 6.0  # 每条叠加线的偏移像素

# 添加一条意图到可视化（叠加到相同 target）
func add_intent(intent: AIActionData) -> void:
	if intent == null:
		return
	selected_action = intent.action
	# 确保 action_ui_layer 存在（尝试自动获取）
	#if action_ui_layer == null:
		#if get_tree().root.has_node("Main/UILayer"):
			#action_ui_layer = get_tree().root.get_node("Main/UILayer")
	# key（按目标格子聚合）
	var key := _grid_key(intent.grid_position)
	if not target_intents.has(key):
		# 新建 container
		var container := Node2D.new()
		container.name = "Intent_" + key
		if action_ui_layer != null:
			action_ui_layer.add_child(container)
		else:
			# 兜底挂到当前场景
			get_tree().current_scene.add_child(container)

		# label 显示总伤害与次数
		var lbl := Label.new()
		lbl.name = "IntentLabel"
		lbl.position = Vector2.ZERO
		container.add_child(lbl)

		target_intents[key] = {
			"intents": [],
			"lines": [],
			"label": lbl,
			"container": container,
			"exec_node": null
		}

	# 把 intent 入队
	var entry:Dictionary = target_intents[key]
	entry["intents"].append(intent)
	intent_to_key[intent] = key

	# 为这条 intent 新建一条浅色线（可视上做偏移）
	var line:Line2D = _create_line_for_intent(intent, entry["intents"].size() - 1, PREVIEW_COLOR, PREVIEW_WIDTH)
	entry["container"].add_child(line)
	entry["lines"].append(line)

	# 更新 label（显示总数和累计伤害）
	var total_damage := 0
	
	for it in entry["intents"]:
		
		total_damage += int(it.predicted_damage)
	var text := "x" + str(entry["intents"].size()) + "  -" + str(total_damage)
	entry["label"].text = text
	# 把 label 放在目标世界坐标上方
	var label_world:Vector2 = GridManager.get_world_position(entry["intents"][0].grid_position) if entry["intents"].size() > 0 else Vector2.ZERO
	entry["label"].global_position = label_world + Vector2(0, +10)  # 向上偏移 30 像素


# 从可视化中移除一条 intent（在执行开始或取消时调用）
func remove_intent(intent: AIActionData) -> void:
	if intent == null:
		return
	if not intent_to_key.has(intent):
		return
	var key = intent_to_key[intent]
	if not target_intents.has(key):
		intent_to_key.erase(intent)
		return
	var entry = target_intents[key]
	# 找到 index
	var idx := -1
	for i in entry["intents"].size():
		if entry["intents"][i] == intent:
			idx = i
			break
	if idx == -1:
		# 如果没找到，尝试逐个 match
		for i in range(entry["intents"].size()):
			if entry["intents"][i] == intent:
				idx = i
				break
	if idx == -1:
		intent_to_key.erase(intent)
		return

	# 移除对应的 line 节点并从数组中删除
	var line_node:Line2D = entry["lines"][idx]
	if is_instance_valid(line_node):
		line_node.queue_free()
	entry["lines"].remove_at(idx)
	# 从 intents 中移除
	entry["intents"].remove_at(idx)
	intent_to_key.erase(intent)

	# 重新更新 label & 重新排列剩余 lines 的偏移
	if entry["intents"].is_empty():
		# 全部移除，删掉 container
		var cnode :Node2D= entry["container"]
		if is_instance_valid(cnode):
			cnode.queue_free()
		target_intents.erase(key)
	else:
		# 更新 total damage 和次数标签
		var total_damage := 0
		for it in entry["intents"]:
			total_damage += int(it.predicted_damage)
		entry["label"].text = "x" + str(entry["intents"].size()) + "  -" + str(total_damage)
		# 重新布局剩下的 lines（更新偏移）
		for i in range(entry["lines"].size()):
			var ln :Line2D= entry["lines"][i]
			_update_line_offset(ln, i - (entry["lines"].size() - 1) / 2.0)  # 中心对齐


# 当某条 intent 开始执行：先把预览移除（remove_intent），然后显示高亮执行路径
func on_intent_executing(intent: AIActionData, exec_target: Vector2i) -> void:
	if intent == null:
		return
	# 先移除预览意图（如果还在）
	remove_intent(intent)

	# 画一条高亮执行路径（保存在 exec_node，以便执行结束时清理）
	var exec_node := Node2D.new()
	exec_node.name = "Exec_" + _grid_key(exec_target)
	if action_ui_layer != null:
		action_ui_layer.add_child(exec_node)
	else:
		get_tree().current_scene.add_child(exec_node)

	var start_world :Vector2= GridManager.get_world_position(intent.unit.grid_position)
	var end_world :Vector2= GridManager.get_world_position(exec_target)

	var line :Line2D= Line2D.new()
	line.width = 4.0
	line.default_color = EXEC_COLOR
	line.points = [start_world, end_world]
	exec_node.add_child(line)

	# 保存到 exec_node（供 on_intent_executed 清理）
	# 把 exec_node 存到一个临时字段（每个 intent 单独存储）
	if not intent.has_meta("exec_node"):
		intent.set_meta("exec_node", exec_node)
	else:
		# 覆盖旧的
		var old :Node2D = intent.get_meta("exec_node")
		if is_instance_valid(old):
			old.queue_free()
		intent.set_meta("exec_node", exec_node)


# 执行完成（action 回调后）清理执行高亮
func on_intent_executed(intent: AIActionData) -> void:
	
	if intent == null:
		return
	
	if not intent.has_meta("exec_node"):
		return
	
	var exec_node : Node2D = intent.get_meta("exec_node")
	if is_instance_valid(exec_node):
		exec_node.queue_free()
	intent.set_meta("exec_node", null)


# 清空全部意图（例如回合结束）
func clear_all() -> void:
	for key in target_intents.keys():
		var entry :Dictionary = target_intents[key]
		if entry.has("container") and is_instance_valid(entry["container"]):
			entry["container"].queue_free()
	target_intents.clear()
	intent_to_key.clear()


# =========== Helper ===========

# 将 grid position 转成唯一 key 字符串
func _grid_key(grid_position: Vector2i) -> String:
	return str(grid_position.x) + "," + str(grid_position.y)

# 创建一条用于 intent 的 Line2D（使用简单的直线或 baked points）
# index 用于偏移（叠加显示）
func _create_line_for_intent(intent: AIActionData, index: int, color: Color, width: float) -> Line2D:
	var from_world :Vector2= GridManager.get_world_position(intent.planned_attacker_position)
	var to_world :Vector2= GridManager.get_world_position(intent.grid_position)

	# 为了支持弧线或多点线，你可以用 Path2D+Curve2D 的 baked points
	var curve :Curve2D= Curve2D.new()
	curve.add_point(from_world)
	# 使用抛物线中点提升视觉感（可选）
	var mid := (from_world + to_world) * 0.5
	mid.y -= 40
	curve.add_point(mid)
	curve.add_point(to_world)

	var baked :PackedVector2Array= curve.get_baked_points()  # PackedVector2Array
	var pts := []
	# 计算偏移向量（垂直于主方向），使多条线不重叠
	var dir :Vector2= (to_world - from_world)
	var perp :Vector2= Vector2(-dir.y, dir.x)
	if perp.length() > 0.001:
		perp = perp.normalized()
	else:
		perp = Vector2(0, 1)
	var offset_amount := (index - 0.5) * OFFSET_STEP  # 中心偏移，使多条对称展开
	var perp_offset := perp * offset_amount

	for p in baked:
		pts.append(p + perp_offset)

	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.points = pts
	return line


# 更新已有 line 的偏移（index_shift 可以是负数或小数，用于重排）
func _update_line_offset(line: Line2D, index_shift: float) -> void:
	# 若 line 没有 points 则跳过
	if line == null:
		return
	var pts := []
	for p in line.points:
		pts.append(p) # shallow copy
	# 计算方向根据第一点-最后点
	if pts.size() < 2:
		return
	var from_world = pts[0]
	var to_world = pts[pts.size() - 1]
	var dir = (to_world - from_world)
	var perp := Vector2(-dir.y, dir.x)
	if perp.length() > 0.001:
		perp = perp.normalized()
	else:
		perp = Vector2(0, 1)
	var perp_offset := perp * (index_shift * OFFSET_STEP)
	for i in range(pts.size()):
		pts[i] = pts[i] + perp_offset
	line.points = pts
