extends Node
class_name Health

signal  health_changed(health_point:int)


@export var max_health: int = 10
var current_health : int 


func _ready() -> void:
	current_health = max_health
	

func take_damage(damage_amount: int) -> void:
	current_health = max(0,current_health - damage_amount )
	health_changed.emit(current_health)
	
