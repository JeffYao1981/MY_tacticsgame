extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var collision_shape_2d: CollisionShape2D = $"../CameraBoundary/CollisionShape2D"


@export var move_speed: int = 200
var limit_left:float
var limit_right:float
var limit_top:float
var limit_bottom:float

func _ready() -> void:
	var boundary_rect:Rect2 = collision_shape_2d.shape.get_rect()
	
	limit_left = collision_shape_2d.to_global(boundary_rect.position).x + get_viewport_rect().size.x / 2 
	limit_top = collision_shape_2d.to_global(boundary_rect.position).y + get_viewport_rect().size.y / 2 
	limit_right = collision_shape_2d.to_global(boundary_rect.end).x - get_viewport_rect().size.x / 2 
	limit_bottom = collision_shape_2d.to_global(boundary_rect.end).y - get_viewport_rect().size.y / 2 
#
#
func _process(delta: float) -> void:
	var move_direction = Input.get_vector("camera_move_left","camera_move_right","camera_move_up","camera_move_down")
	var target_postion = global_position + move_direction * move_speed * delta
	target_postion.x = clamp(target_postion.x , limit_left , limit_right)
	target_postion.y = clamp(target_postion.y , limit_top , limit_bottom)
	global_position = target_postion
	#
	
