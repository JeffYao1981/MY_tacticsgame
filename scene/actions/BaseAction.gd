extends Node
class_name BaseAction


@export var action_id:String
@export var action_name:String
@export var grid_color:Color = Color.WHITE
@export var action_point_cost:int = 1
@export var range_show:AnimatedSprite2D
@export var action_icon:Texture2D



var unit: Unit
var is_active: bool = false #是否正在执行
var on_action_finished: Callable


func _ready() -> void:
	unit = owner

	
func set_range_icon() -> void:
	range_show = null
	for child in get_children():
		if child is AnimatedSprite2D:
			range_show = child
			break  # 找到就退出循环
	# 如果没找到，才用 unit 的
	if range_show == null:
		range_show = unit.animated_sprite_range_show
		
	range_show.z_index = 5
	
	if range_show == null:
		print("我是空值")
	if unit.animated_sprite_range_show == null:
		print("角色的动画也是空值")
	
	
	
func start_action(target_grid_position:Vector2i,on_action_finished:Callable) ->void:
	is_active = true
	self.on_action_finished = on_action_finished
	unit.current_action_points -= action_point_cost
	GridManager.visual_layer.clear()
	
	
func finish_action() ->void:
	is_active = false	
	on_action_finished.call()
	if unit.current_action_points >= action_point_cost :
		GridManager.visualize_grids(PlayerActionManager.selected_action.get_action_grids(),PlayerActionManager.selected_action.grid_color)
		PlayerActionManager.range_box_switch = true
	#elif :
		
func get_action_grids(unit_grid:Vector2i = unit.grid_position) -> Array[Vector2i]:
	return []


func is_obstacle(grid_position:Vector2i) -> bool:#判断网格是否障碍物
	if GridManager.is_grid_occupied(grid_position):
		return false
	return not GridManager.is_grid_walkable(grid_position)



func is_occupied_by_allay(grid_position:Vector2i) -> bool:#判断该网格否被队友占据
	if not  GridManager.is_grid_occupied(grid_position):
		return false
	return GridManager.get_grid_occupied(grid_position).is_enemy == unit.is_enemy
	

func hit_obstacle(starting_grid:Vector2i,ending_grid:Vector2i) -> bool:#判断路线(数组中是否有碰撞物）是否有障碍物
	var starting_position: Vector2 = GridManager.get_world_position(starting_grid)
	var ending_position: Vector2 = GridManager.get_world_position(ending_grid)
	var query_parameters =  PhysicsRayQueryParameters2D.create(starting_position,ending_position,2)
	var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
	return not result.is_empty()

	
