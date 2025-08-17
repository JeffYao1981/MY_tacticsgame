extends Node

signal unit_selected(unit: Unit)


var is_performing_action: bool = false	#正在performing（履行）动作
var selected_action:BaseAction 
var selected_unit: Unit




func set_selected_unit(unit:Unit) ->void:
	if is_performing_action:
		return
	if selected_unit == unit or unit.is_enemy:
		return
	
	selected_unit = unit
	print(unit.name + "selected")
	unit_selected.emit(selected_unit)
	set_selected_action(unit.actions_manager.get_action("move_action"))#选择角色后默认选择的action

		
func set_selected_action(action:BaseAction) ->void:
	if is_performing_action:
		return
	if selected_action == action:
		return
		
	
	selected_action = action
	
	
	if selected_unit.current_action_points >= selected_action.action_point_cost:
		GridManager.visualize_grids(selected_action.get_action_grids(),selected_action.grid_color)
	else :	
		GridManager.visual_layer.clear()
	

func  try_perform_selected_action()-> void:
	if is_performing_action:
		return
	if selected_action == null:
		return
	var target_grid_position: Vector2i = GridManager.get_mouse_grid_position()
	if not selected_action.get_action_grids().has(target_grid_position):
		return
	if selected_unit.current_action_points < selected_action.action_point_cost:
		return
	
	is_performing_action = true
	
	selected_action.start_action(target_grid_position,on_action_finished)


func on_action_finished() ->void:
	is_performing_action = false
