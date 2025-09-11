extends Node


var indicators: Array[Node] = []





# 展示一个敌人意图
func show(intent: AIActionData) -> void:
	if intent == null or intent.action == null:
		return

	# --- 获取范围动画贴图 ---
	intent.action.set_range_icon()
	var range_icon: AnimatedSprite2D = intent.action.range_show
	if range_icon == null:
		return
	
	# 创建副本（避免直接操作 action 自带的节点）
	var indicator := range_icon.duplicate()
	indicator.play("run") # 需要你的动画里有 "show" 动画
	indicator.global_position = GridManager.get_world_position(intent.grid_position)

	get_tree().current_scene.add_child(indicator)
	indicators.append(indicator)
	
	
	# --- 显示攻击意图 ---
	if intent.grid_position != null and not (intent.action is MoveAciton):
		var label := Label.new()
		label.text = "伤害: %d" % intent.action.damage_amount
		label.global_position = GridManager.get_world_position(intent.grid_position) + Vector2(0, -32)
		label.add_theme_color_override("font_color", Color.RED)
		get_tree().current_scene.add_child(label)
		indicators.append(label)


# 清理所有可视化
func clear() -> void:
	for i in indicators:
		if is_instance_valid(i):
			i.queue_free()
	indicators.clear()


# 确保场景切换时也能清理
func _on_node_removed(node: Node) -> void:
	if node in indicators:
		indicators.erase(node)
