extends Node2D
class_name Unit

signal unit_died(unit:Unit)
signal action_point_changed(action_point: int)
@onready var unit_actions_ui: UnitActionsUI = $UnitActionsUI

@onready var unit_area: Area2D = $UnitArea
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_slot: Node2D = $AnimatedSprite2D/WeaponSlot


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var weapon_slot_2: Node2D = $WeaponSlot2
@onready var animated_sprite_range_show: AnimatedSprite2D = $AnimatedSpriteRangeShow

#声音
@onready var unit_hit_sound_player: AudioStreamPlayer = $Sound/UnitHitSoundPlayer
@onready var unit_dead_sound_player: AudioStreamPlayer = $Sound/UnitDeadSoundPlayer
@onready var actions_manager: ActionManager = $ActionsManager


# 阵营枚举（Player / Enemy / Red / Black / Neutral）
enum Faction { Player, Enemy, Red, Black, Neutral }
@export var faction: int = Faction.Player
@export var is_enemy : bool = false  #可以做成枚举，添加中立单位




#兵种枚举
enum UnitType {
	INFANTRY,   # 步兵
	CAVALRY,    # 骑兵
	FLYING,     # 飞行单位
	PHASE,      # 穿透单位
}
@export var unit_type: UnitType = UnitType.INFANTRY

# 标记是否为象棋单位（由场景配置）
@export var is_chess_piece: bool = false
# chess_side: "red" / "black"（也可以使用 faction 字段）
@export var chess_side: String = ""

#生命值
@onready var health: Health = $Health
@export var max_hp: int = 10
var current_hp: int


# 行动力（AP）
@export var action_points:int = 2
var current_action_points:int:
	set (value):
		current_action_points = value
		action_point_changed.emit(current_action_points)
# 移动/速度/战斗基础数值
@export var move_range: int = 3
@export var move_speed: float = 120.0
@export var attack_power: int = 5
@export var defense: int = 0

#死亡		
var is_dead :bool = false

var grid_position:Vector2i:
	get: return GridManager.get_grid_position(global_position)
	
	
func _ready() -> void:
	if is_enemy:
		faction = Faction.Enemy
	current_hp = max_hp
	current_action_points = action_points
	
	TurnManager.player_turn_started.connect(on_player_turn_started)
	TurnManager.enemy_turn_started.connect(on_enemy_turn_started)
	# 新信号
	if TurnManager.has_method("connect"):
		if TurnManager.has_signal("red_turn_started"):
			TurnManager.red_turn_started.connect(on_red_turn_started)
		if TurnManager.has_signal("black_turn_started"):
			TurnManager.black_turn_started.connect(on_black_turn_started)
	
	# 点击选择
	unit_area.unit_selected.connect(on_unit_selected)
	
	health.health_changed.connect(on_health_changed)
	# 注册进 GameManager
	GameManager.register_unit(self)
	if is_chess_piece:
		var is_red := chess_side.to_lower() == "red" or faction == Faction.Red
		
		ChessAiManager.register_unit(self, is_red)
			
				
func on_unit_selected() ->void:
	PlayerActionManager.set_selected_unit(self)
	
	
func take_damage(damage_amount:int) -> void:
	print(name + "受到了"+ str(damage_amount)+"点伤害")
	health.take_damage(damage_amount)
	
	
func on_player_turn_started() -> void:
	if faction == Faction.Player:
		current_action_points = action_points
	
func on_enemy_turn_started() -> void:
	if faction == Faction.Enemy:
		current_action_points = action_points

func on_red_turn_started()-> void:
	if is_chess_piece and (chess_side.to_lower() == "red" or faction == Faction.Red):
		current_action_points = action_points

func on_black_turn_started()-> void:
	if is_chess_piece and (chess_side.to_lower() == "black" or faction == Faction.Black):
		current_action_points = action_points

func get_available_actions() -> Array:
	return actions_manager.actions
	
func on_health_changed(health_point:int) -> void:
	if health_point <= 0 :
		die()
	
func die() ->void:
	is_dead = true
	GridManager.set_grid_occupied(grid_position,null)
	GridManager.set_grid_walkable(grid_position,true)
	GameManager.unregister_unit(self)
	unit_dead_sound_player.play()
	unit_died.emit(self)
	if animated_sprite_2d :
		animated_sprite_2d.play("die")
		await animated_sprite_2d.animation_finished
	else :
		animation_player.play("die")
		await animation_player.animation_finished
	queue_free()
