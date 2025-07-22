extends Node2D
class_name Unit
@onready var unit_area: Area2D = $UnitArea



@onready var actions_manager: ActionManager = $ActionsManager
@export var is_enemy : bool = false  #可以做成枚举，添加中立单位

var grid_position:Vector2i:
	get: return GridManager.get_grid_position(global_position)
	
	
func _ready() -> void:
	unit_area.unit_selected.connect(on_unit_selected)
	GameManager.register_unit(self)
		
func on_unit_selected() ->void:
	PlayerActionManager.set_selected_unit(self)
	
	
	
	
	
	
