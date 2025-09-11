extends Node

# 新的细分回合信号（保留 player_turn_started / enemy_turn_started 兼容）
signal enemy_intent_started
signal player_turn_started
signal enemy_execute_started
signal red_turn_started
signal black_turn_started

# 向后兼容
signal enemy_turn_started

@onready var state_machine: StateMachine


func start_enemy_intent() -> void:
	enemy_intent_started.emit()
	

func start_player_turn() ->void:
	player_turn_started.emit()
	
func start_enemy_turn() ->void:
	enemy_turn_started.emit()
	# 同时触发新的 execute 阶段（默认行为）
	start_enemy_execute()

func start_enemy_execute() -> void:
	enemy_execute_started.emit()

func start_red_turn() -> void:
	red_turn_started.emit()

func start_black_turn() -> void:
	black_turn_started.emit()

func is_player_turn() -> bool:
	return state_machine.current_state.state_name == "PlayerTurnState"
