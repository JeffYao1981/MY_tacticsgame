extends Node2D
class_name Unit

signal unit_died(unit:Unit)
signal action_point_changed(action_point: int)

@onready var unit_area: Area2D = $UnitArea
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_slot: Node2D = $AnimatedSprite2D/WeaponSlot
@onready var health: Health = $Health
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var weapon_slot_2: Node2D = $WeaponSlot2
@onready var animated_sprite_range_show: AnimatedSprite2D = $AnimatedSpriteRangeShow




@onready var actions_manager: ActionManager = $ActionsManager
@export var is_enemy : bool = false  #可以做成枚举，添加中立单位
@export var action_points:int = 2

var current_action_points:int:
	set (value):
		current_action_points = value
		action_point_changed.emit(current_action_points)
var is_dead :bool = false

var grid_position:Vector2i:
	get: return GridManager.get_grid_position(global_position)
	
	
func _ready() -> void:
	TurnManager.player_turn_started.connect(on_player_turn_started)
	TurnManager.enemy_turn_started.connect(on_enemy_turn_started)
	unit_area.unit_selected.connect(on_unit_selected)
	health.health_changed.connect(on_health_changed)
	current_action_points = action_points
	GameManager.register_unit(self)
		
func on_unit_selected() ->void:
	PlayerActionManager.set_selected_unit(self)
	
func take_damage(damage_amount:int) -> void:
	print(name + "受到了"+ str(damage_amount)+"点伤害")
	health.take_damage(damage_amount)
	
func on_player_turn_started() -> void:
	if is_enemy:
		return
	current_action_points = action_points
	
func on_enemy_turn_started() -> void:
	if is_enemy:
		current_action_points = action_points
	
func on_health_changed(health_point:int) -> void:
	if health_point <= 0 :
		die()
	
func die() ->void:
	is_dead = true
	GridManager.set_grid_occupied(grid_position,null)
	GridManager.set_grid_walkable(grid_position,true)
	GameManager.unregister_unit(self)
	unit_died.emit(self)
	if animated_sprite_2d :
		animated_sprite_2d.play("die")
		await animated_sprite_2d.animation_finished
	else :
		animation_player.play("die")
		await animation_player.animation_finished
	queue_free()
