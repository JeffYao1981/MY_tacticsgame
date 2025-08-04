extends Node

signal player_turn_started()
signal enemy_turn_started()

@onready var state_machine: StateMachine




func start_player_turn() ->void:
	player_turn_started.emit()
	
	
func start_enemy_turn() ->void:
	enemy_turn_started.emit()

func is_player_turn() -> bool:
	return state_machine.current_state.state_name == "PlayerTurnState"
