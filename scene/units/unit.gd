extends Node2D
class_name Unit
@onready var unit_area: Area2D = $UnitArea
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_slot: Node2D = $AnimatedSprite2D/WeaponSlot



@onready var actions_manager: ActionManager = $ActionsManager
@export var is_enemy : bool = false  #可以做成枚举，添加中立单位
@export var action_points:int = 2

var current_action_points:int

var grid_position:Vector2i:
	get: return GridManager.get_grid_position(global_position)
	
	
func _ready() -> void:
	TurnManager.player_turn_started.connect(on_player_turn_started)
	TurnManager.enemy_turn_started.connect(on_enemy_turn_started)
	unit_area.unit_selected.connect(on_unit_selected)
	current_action_points = action_points
	GameManager.register_unit(self)
		
func on_unit_selected() ->void:
	PlayerActionManager.set_selected_unit(self)
	
func take_damage(damage_amount:int) -> void:
	print(name + "受到了"+ str(damage_amount)+"点伤害")
	
func on_player_turn_started() -> void:
	if is_enemy:
		return
	current_action_points = action_points
	
func on_enemy_turn_started() -> void:
	if is_enemy:
		current_action_points = action_points
	

	
