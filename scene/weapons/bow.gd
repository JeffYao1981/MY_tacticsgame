extends Node2D
class_name Bow

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shoot_point: Node2D = $ShootPoint

@export var arrow_scene : PackedScene

var finish_action:Callable
var unit:Unit
var target_grid_position:Vector2i

func set_up(finish_action:Callable,unit:Unit,target_grid_position:Vector2i) -> void:
	self.finish_action = finish_action
	self.unit = unit
	self.target_grid_position = target_grid_position
	
	if target_grid_position.y > unit.grid_position.y :
		rotation_degrees = 90
	if target_grid_position.y < unit.grid_position.y :
		rotation_degrees = -90
		
	animation_player.play("shoot")

func shoot() -> void:
	var arrow:Projectile = arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	arrow.global_position = shoot_point.global_position
	arrow.set_up(finish_action,unit,target_grid_position)
