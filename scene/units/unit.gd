extends Node2D
class_name Unit
@onready var unit_area: Area2D = $UnitArea
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_slot: Node2D = $AnimatedSprite2D/WeaponSlot



@onready var actions_manager: ActionManager = $ActionsManager
@export var is_enemy : bool = false  #可以做成枚举，添加中立单位

var grid_position:Vector2i:
	get: return GridManager.get_grid_position(global_position)
	
	
func _ready() -> void:
	unit_area.unit_selected.connect(on_unit_selected)
	GameManager.register_unit(self)
		
func on_unit_selected() ->void:
	PlayerActionManager.set_selected_unit(self)
	
func take_damage(damage_amount:int) -> void:
	print(name + "受到了"+ str(damage_amount)+"点伤害")
	
	
	
	
