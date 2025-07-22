extends Node

signal player_turn_started()
signal enemy_turn_started()


func start_player_turn() ->void:
	player_turn_started.emit()
	
	
func start_enemy_turn() ->void:
	enemy_turn_started.emit()
