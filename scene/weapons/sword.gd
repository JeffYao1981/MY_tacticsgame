extends Node2D
class_name Sword


@onready var animation_player: AnimationPlayer = $AnimationPlayer

var finish_action:Callable
var unit:Unit
var damager_amount:int = 5
var target: Unit

func set_up(finish_action:Callable,unit:Unit,target_grid_position:Vector2i) ->void:
	self.finish_action = finish_action
	self.unit = unit
	target = GridManager.get_grid_occupied(target_grid_position)
	if target_grid_position.y > unit.grid_position.y:
		rotation_degrees = 180
	elif target_grid_position.y < unit.grid_position.y:
		rotation_degrees = 0
	else :
		rotation_degrees = 90
	animation_player.play("attack")
	
func deal_damage() ->void :
	if target != null and target.is_enemy != unit.is_enemy:
		target.take_damage(damager_amount)
	
func animation_finished() ->void:
	finish_action.call()	
	queue_free()
