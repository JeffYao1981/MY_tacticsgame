extends MarginContainer

@onready var end_turn_button: Button = $EndTurnButton
@onready var turn_label: Label = $TurnLabel


func _ready() -> void:
	  
	end_turn_button.pressed.connect(on_end_turn_button_pressed)
	TurnManager.玩家回合.connect(on_player_turn_started)
	TurnManager.敌人意图回合.connect(on_enemy_intent_started)
	TurnManager.敌人攻击回合.connect(on_enemy_execute_started)
	TurnManager.红棋行动.connect(on_red_turn_started)
	TurnManager.黑棋行动.connect(on_black_turn_started)
	# 兼容旧信号
	TurnManager.enemy_turn_started.connect(on_enemy_turn_started)
	
	#声音
	AudioManager.register_button(end_turn_button)
	
func on_end_turn_button_pressed() ->void:
	
	if PlayerActionManager.is_performing_action or EnemyActionManage.is_performing_action:
		return
	if TurnManager.state_machine.current_state.state_name != "PlayerTurnState":
		return
	TurnManager.state_machine.current_state.change_state("EnemyExecuteState")
	
	
func on_player_turn_started() ->void:
	turn_label.text = "玩家回合"

func on_enemy_intent_started() -> void:
	turn_label.text = "敌人行动"

func on_enemy_execute_started() -> void:
	turn_label.text = "敌人攻击"

func on_red_turn_started() -> void:
	turn_label.text = "红棋行动"

func on_black_turn_started() -> void:
	turn_label.text = "黑棋行动"
	
func on_enemy_turn_started() ->void:
	turn_label.text = "Enemy Turn"
