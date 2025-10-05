#extends Node2D
#class_name Projectile
#
#var finish_action:Callable
#var unit:Unit
#var target_grid_position:Vector2i
#var target_world_position:Vector2
#
#@export var impact_effect_scene:PackedScene
#@export var damage_amount:int = 5
#@export var speed:int = 200
#
#
#func set_up(finish_action:Callable,unit:Unit,target_grid_position:Vector2i) -> void:
	#self.finish_action = finish_action
	#self.unit = unit
	#self.target_grid_position = target_grid_position
	#target_world_position = GridManager.get_world_position(target_grid_position)
	#look_at(target_world_position)
	#
#func deal_damage() -> void:
	#var target:Unit = GridManager.get_grid_occupied(target_grid_position)
	#if target and target.is_enemy != unit.is_enemy:
		#target.take_damage(damage_amount)
		#
#func _process(delta: float) -> void:
	#global_position = global_position.move_toward(target_world_position,speed*delta)
	#if global_position == target_world_position:
		#if impact_effect_scene != null:
			#var impact_effect:Node2D = impact_effect_scene.instantiate()
			#get_tree().current_scene.add_child(impact_effect)
			#impact_effect.global_position = global_position
			#
		#deal_damage()
		#finish_action.call()
		#queue_free()

extends Node2D
class_name Projectile

var finish_action: Callable
var unit: Unit
var target_grid_position: Vector2i
var target_world_position: Vector2

@export var impact_effect_scene: PackedScene
var damage_amount:int
@export var speed: int = 200
@export var arc_height: float = 20.0  # 弧线高度

# 抛物线飞行变量
var start_position: Vector2
var travel_progress: float = 0.0
var total_distance: float = 0.0
var previous_position: Vector2

func set_up(finish_action: Callable, unit: Unit, target_grid_position: Vector2i) -> void:
	
	self.finish_action = finish_action
	self.unit = unit
	self.target_grid_position = target_grid_position
	target_world_position = GridManager.get_world_position(target_grid_position)
	if unit.is_enemy:
		
		damage_amount = EnemyIntentVisualizer.selected_action.damage_amount	
	else :
		damage_amount = PlayerActionManager.selected_action.damage_amount
	# 记录起始位置和计算总距离
	start_position = global_position
	previous_position = global_position
	total_distance = start_position.distance_to(target_world_position)
	
	# 初始朝向目标方向
	look_at(target_world_position)

func deal_damage() -> void:
	var target: Unit = GridManager.get_grid_occupied(target_grid_position)
	if target and target.is_enemy != unit.is_enemy:
		target.take_damage(damage_amount)

func _process(delta: float) -> void:
	# 计算移动进度
	var move_distance = speed * delta
	travel_progress += move_distance / total_distance
	
	# 限制进度在0-1之间
	travel_progress = min(travel_progress, 1.0)
	
	if travel_progress >= 1.0:
		# 到达目标
		global_position = target_world_position
		
		#if impact_effect_scene != null:
			#var impact_effect: Node2D = impact_effect_scene.instantiate()
			#get_tree().current_scene.add_child(impact_effect)
			#impact_effect.global_position = global_position
			
		deal_damage()
		finish_action.call()
		queue_free()
	else:
		# 计算水平位置（线性插值）
		var horizontal_position = start_position.lerp(target_world_position, travel_progress)
		
		# 计算抛物线高度（使用抛物线公式，在中点最高）
		var height_offset = arc_height * 4 * travel_progress * (1 - travel_progress)
		
		# 计算新位置
		var new_position = horizontal_position + Vector2(0, -height_offset)
		
		# 计算运动方向并旋转弓箭
		var movement_direction = new_position - previous_position
		if movement_direction.length() > 0:
			rotation = movement_direction.angle()
		
		# 更新位置
		previous_position = global_position
		global_position = new_position
