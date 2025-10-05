extends Node
class_name BaseAction


@export var action_id:String
@export var action_name:String
@export var grid_color:Color = Color.WHITE
@export var action_point_cost:int = 1
@export var range_show:AnimatedSprite2D
@export var action_icon:Texture2D

signal clear_action_card
signal add_action_card

var unit: Unit
var is_active: bool = false #是否正在执行
var on_action_finished: Callable
var can_cancel:bool = false
var move_history := []
var action_intent :AIActionData
@export var damage_amount:int


func _ready() -> void:
	unit = owner

	
func set_range_icon() -> void:
	if unit.is_chess_piece:
		return
	
	range_show = null
	for child in get_children():
		if child is AnimatedSprite2D:
			range_show = child
			break  # 找到就退出循环
	# 如果没找到，才用 unit 的
	if range_show == null:
		range_show = unit.animated_sprite_range_show
		
	range_show.z_index = 5
	
	#if range_show == null:
		#print("我是空值")
	#if unit.animated_sprite_range_show == null:
		#print("角色的动画也是空值")
	
	
	
func start_action(target_grid_position:Vector2i,on_action_finished:Callable) ->void:
	is_active = true
	can_cancel = true
	move_history.append({
		"grid_pos": unit.grid_position,
		"global_pos": unit.global_position,
		"action_point_cost": action_point_cost,
		"action_performed": false  # 攻击或不可撤销动作时设置 true
	})
	
	self.on_action_finished = on_action_finished
	unit.current_action_points -= action_point_cost
	GridManager.visual_layer.clear()
	clear_action_card.emit()
	
func cancel_action()->void:
	if !can_cancel:
		return
	if move_history.is_empty():
		return
	GridManager.set_grid_walkable(unit.grid_position,true)
	GridManager.set_grid_occupied(unit.grid_position,null)
	GridManager.nav_layer.a_star.set_point_solid(unit.grid_position,false)
	clear_action_card.emit()
	var last_state = move_history.pop_back()
	unit.grid_position = last_state.grid_pos
	unit.global_position = last_state.global_pos
	unit.current_action_points += action_point_cost
	
	GridManager.set_grid_walkable(last_state.grid_pos,false)
	GridManager.set_grid_occupied(last_state.grid_pos,unit)
	GridManager.visualize_grids(PlayerActionManager.selected_action.get_action_grids(),PlayerActionManager.selected_action.grid_color)
	add_action_card.emit()
	
	
func finish_action() ->void:
	is_active = false	
	on_action_finished.call()
	if unit.current_action_points >= action_point_cost and !unit.is_enemy :
		GridManager.visualize_grids(PlayerActionManager.selected_action.get_action_grids(),PlayerActionManager.selected_action.grid_color)
		PlayerActionManager.range_box_switch = true
		add_action_card.emit()
	if unit.is_enemy:
		print(self.action_name,"清理UI")
		EnemyIntentVisualizer.on_intent_executed(action_intent)
		
func get_action_grids(unit_grid:Vector2i = unit.grid_position) -> Array[Vector2i]:
	return []


func is_obstacle(grid_position:Vector2i) -> bool:#判断网格是否障碍物
	if GridManager.is_grid_occupied(grid_position):
		return false
	return not GridManager.is_grid_walkable(grid_position)

func predict_damage(target: Unit) -> int:
	
	return damage_amount

func is_occupied_by_allay(grid_position:Vector2i) -> bool:#判断该网格否被队友占据
	#if not  GridManager.is_grid_occupied(grid_position):
		#return false
	#return GridManager.get_grid_occupied(grid_position).is_enemy == unit.is_enemy
	if not GridManager.is_grid_occupied(grid_position):
		return false
	var occupant :Unit= GridManager.get_grid_occupied(grid_position)
	if occupant == null:
		return false
	# 要求 unit 有 faction 属性
	if unit != null and occupant.faction == unit.faction:
		return true
	# 向后兼容：若没 faction 则使用 is_enemy 布尔比较（旧逻辑）
	if occupant.is_enemy == unit.is_enemy:
		return true
		
	return false

func hit_obstacle(starting_grid:Vector2i,ending_grid:Vector2i) -> bool:#判断路线(数组中是否有碰撞物）是否有障碍物
	var starting_position: Vector2 = GridManager.get_world_position(starting_grid)
	var ending_position: Vector2 = GridManager.get_world_position(ending_grid)
	var query_parameters =  PhysicsRayQueryParameters2D.create(starting_position,ending_position,2)
	var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
	return not result.is_empty()



# 真正执行，结算伤害/位移
func execute(intent: AIActionData, on_finished: Callable) -> void:
	# 默认实现直接调用 start_action
	start_action(intent.grid_position, on_finished)	
