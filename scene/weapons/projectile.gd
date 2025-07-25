extends Node2D
class_name Projectile

var finish_action:Callable
var unit:Unit
var target_grid_position:Vector2i
var target_world_position:Vector2

@export var impact_effect_scene:PackedScene
@export var damage_amount:int = 5
@export var speed:int = 200


func set_up(finish_action:Callable,unit:Unit,target_grid_position:Vector2i) -> void:
	self.finish_action = finish_action
	self.unit = unit
	self.target_grid_position = target_grid_position
	target_world_position = GridManager.get_world_position(target_grid_position)
	look_at(target_world_position)
	
func deal_damage() -> void:
	var target:Unit = GridManager.get_grid_occupied(target_grid_position)
	if target and target.is_enemy != unit.is_enemy:
		target.take_damage(damage_amount)
		
func _process(delta: float) -> void:
	global_position = global_position.move_toward(target_world_position,speed*delta)
	if global_position == target_world_position:
		if impact_effect_scene != null:
			var impact_effect:Node2D = impact_effect_scene.instantiate()
			get_tree().current_scene.add_child(impact_effect)
			impact_effect.global_position = global_position
			
		deal_damage()
		finish_action.call()
		queue_free()
