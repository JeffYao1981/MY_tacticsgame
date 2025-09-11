extends MarginContainer

@onready var end_turn_button: Button = $EndTurnButton
@onready var turn_label: Label = $TurnLabel


func _ready() -> void:
	
	end_turn_button.pressed.connect(on_end_turn_button_pressed)
	TurnManager.player_turn_started.connect(on_player_turn_started)
	TurnManager.enemy_intent_started.connect(on_enemy_intent_started)
	TurnManager.enemy_execute_started.connect(on_enemy_execute_started)
	TurnManager.red_turn_started.connect(on_red_turn_started)
	TurnManager.black_turn_started.connect(on_black_turn_started)
	# 兼容旧信号
	TurnManager.enemy_turn_started.connect(on_enemy_turn_started)
	
	#声音
	AudioManager.register_button(end_turn_button)
	
func on_end_turn_button_pressed() ->void:
	if PlayerActionManager.is_performing_action or EnemyActionManage.is_performing_action:
		return
	TurnManager.start_enemy_execute()
	
func on_player_turn_started() ->void:
	turn_label.text = "Player Turn"

func on_enemy_intent_started() -> void:
	turn_label.text = "Enemy Intent"

func on_enemy_execute_started() -> void:
	turn_label.text = "Enemy Execute"

func on_red_turn_started() -> void:
	turn_label.text = "Red (Xiangqi) Turn"

func on_black_turn_started() -> void:
	turn_label.text = "Black (Xiangqi) Turn"
	
func on_enemy_turn_started() ->void:
	turn_label.text = "Enemy Turn"
