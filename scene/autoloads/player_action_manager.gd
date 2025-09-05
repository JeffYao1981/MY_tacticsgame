extends Node

signal unit_selected(unit: Unit)


var is_performing_action: bool = false	#正在performing（履行）动作
var selected_action:BaseAction 
var selected_unit: Unit
var mouse_grid_position:Vector2i
var range_box_switch:bool = false
@onready var sprite_2d: Sprite2D = $Sprite2D

#var range_box_show:AnimatedSprite2D

func set_selected_unit(unit:Unit) ->void:
	if is_performing_action:
		return
	if selected_unit == unit or unit.is_enemy:
		return
	#if selected_unit:#这里判断UI的隐藏和显示
		#selected_unit.unit_actions_ui.visible = false
		#var action_card = selected_unit.unit_actions_ui.action_container
		#for card_ui in action_card.get_children():
			#card_ui.animation_player.play("button_in")
			#print("UI来了")
	selected_unit = unit
	
	
	print(unit.name + "selected")
	unit_selected.emit(selected_unit)
	set_selected_action(unit.actions_manager.get_action("move_action"))#选择角色后默认选择的action

		
func set_selected_action(action:BaseAction) ->void:
	if is_performing_action:
		return
	if selected_action == action:
		return
	if selected_action:
		selected_action.range_show.visible = false
	selected_action = action
	selected_action.set_range_icon()
	if selected_unit.current_action_points >= selected_action.action_point_cost:
		GridManager.visualize_grids(selected_action.get_action_grids(),selected_action.grid_color)
		range_box_switch = true
	else :	
		GridManager.visual_layer.clear()
	
	

#func range_box_move(delta: float) -> void:
	#var new_mouse_grid_position = GridManager.get_mouse_grid_position()
	#
	#if selected_action.get_action_grids().has(new_mouse_grid_position):
		#selected_action.range_show.visible = true
		##selected_action.range_show.visible = true
	#
		#
		#var unit_world_x = GridManager.get_world_position(selected_unit.grid_position).x
	#
	#
		#if mouse_grid_position.x >= unit_world_x:
			#selected_action.range_show.scale = Vector2(1, 1)
		#else:
			#selected_action.range_show.scale = Vector2(-1, 1)	
			#
		#if new_mouse_grid_position != mouse_grid_position:
			#mouse_grid_position = new_mouse_grid_position
			##selected_action.range_show.global_position = GridManager.get_world_position(mouse_grid_position)
			#selected_action.range_show.global_position = GridManager.get_world_position(mouse_grid_position)
			#
		#else :
			##selected_action.range_show.visible = false
			#selected_action.range_show.visible = false
		

func range_box_move(delta: float) -> void:
	
	var new_mouse_grid_position = GridManager.get_mouse_grid_position()
	
	if not is_instance_valid(selected_action) or not is_instance_valid(selected_unit):#角色死亡被注销后的逻辑
		
		return
	
	if selected_action.get_action_grids().has(new_mouse_grid_position):
		
		selected_action.range_show.visible = true
		
		var unit_world_x = GridManager.get_world_position(selected_unit.grid_position).x
		
		# 直接用 new_mouse_grid_position 判断方向
		if new_mouse_grid_position.x >= selected_unit.grid_position.x:
			selected_action.range_show.scale = Vector2(1, 1)
		else:
			selected_action.range_show.scale = Vector2(-1, 1)
		
		# 更新位置
		mouse_grid_position = new_mouse_grid_position
		selected_action.range_show.global_position = GridManager.get_world_position(mouse_grid_position)
	else:
		selected_action.range_show.visible = false
		
		
func _process(delta: float) -> void:
	if not range_box_switch :
		return
	
	range_box_move(delta)

func  try_perform_selected_action()-> void:
	if is_performing_action:
		return
	if selected_action == null:
		return
	var target_grid_position: Vector2i = GridManager.get_mouse_grid_position()
	
	#如果是get_action_grids()范围外的网格，就不起作用
	if not selected_action.get_action_grids().has(target_grid_position):
		return
	#如果行动点不够也没有反应
	if selected_unit.current_action_points < selected_action.action_point_cost:
		return
	
	is_performing_action = true
	range_box_switch = false
	selected_action.range_show.visible = false
	
	selected_action.start_action(target_grid_position,on_action_finished)

func try_cancel_selected_action() -> bool:#回滚操作
	if selected_unit == null:
		show_message("没有选中的角色")
		return false
	if selected_action == null:
		show_message("没有选中的动作")
		return false
	if not selected_action.can_cancel:
		print("can_cancel:",selected_action.can_cancel)
		show_message("该动作不可撤销")
		return false
	if selected_action.move_history.is_empty():
		show_message("没有更多移动可以撤销")
		return false
	var last_state = selected_action.move_history.back()
	if last_state:
		if GridManager.is_grid_occupied(last_state.grid_pos):
			show_message("目标格子被其他角色占用，无法撤销")
			return false
	selected_action.cancel_action()
	return true
	
	
func show_message(msg: String):
	print(msg)
	
func on_action_finished() ->void:
	is_performing_action = false
	
