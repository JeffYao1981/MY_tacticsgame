extends Node2D
class_name Unit



@onready var actions_manager: ActionManager = $ActionsManager
@export var is_enemy : bool = false

var grid_position:Vector2i:
	get: return GridManager.get_grid_position(global_position)
	
	

		
