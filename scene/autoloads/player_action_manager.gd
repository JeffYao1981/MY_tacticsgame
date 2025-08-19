extends Node

signal unit_selected(unit: Unit)


var is_performing_action: bool = false	#正在performing（履行）动作
var selected_action:BaseAction 
var selected_unit: Unit
var mouse_grid_position:Vector2i
var range_box_switch:bool = false
@onready var sprite_2d: Sprite2D = $Sprite2D
var range_show:AnimatedSprite2D
#var range_box_show:AnimatedSprite2D

func set_selected_unit(unit:Unit) ->void:
	if is_performing_action:
		return
	if selected_unit == unit or unit.is_enemy:
		return
	
	selected_unit = unit
	
	#range_box_show = selected_action.range_show
	print(unit.name + "selected")
	unit_selected.emit(selected_unit)
	set_selected_action(unit.actions_manager.get_action("move_action"))#选择角色后默认选择的action

		
func set_selected_action(action:BaseAction) ->void:
	if is_performing_action:
		return
	if selected_action == action:
		return
		
	selected_action = action
	selected_action.set_range_icon()
	if selected_unit.current_action_points >= selected_action.action_point_cost:
		GridManager.visualize_grids(selected_action.get_action_grids(),selected_action.grid_color)
		range_box_switch = true
	else :	
		GridManager.visual_layer.clear()
	
	

func range_box_move(delta: float) -> void:
	var new_mouse_grid_position = GridManager.get_mouse_grid_position()
	
	if selected_action.get_action_grids().has(new_mouse_grid_position):
		#selected_action.range_show.visible = true
		selected_action.range_show.visible = true
		print("我显示出来了")
		if new_mouse_grid_position != mouse_grid_position:
			mouse_grid_position = new_mouse_grid_position
			#selected_action.range_show.global_position = GridManager.get_world_position(mouse_grid_position)
			selected_action.range_show.global_position = GridManager.get_world_position(mouse_grid_position)
			print("我的位置是：",mouse_grid_position)
	else :
		#selected_action.range_show.visible = false
		selected_action.range_show.visible = false
		print("我关闭了")
		
		
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
	#selected_action.range_show.visible = false
	selected_action.start_action(target_grid_position,on_action_finished)


func on_action_finished() ->void:
	is_performing_action = false
