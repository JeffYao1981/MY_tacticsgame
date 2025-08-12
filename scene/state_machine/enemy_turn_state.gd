extends BaseState


var go_to_player_turn:bool = false

func on_state_enter() -> void:
	
	TurnManager.player_turn_started.connect(on_player_turn_started)
	
	

func on_state_frame_update(delta:float) -> void:
	if go_to_next_turn:
		state_changed.emit("PlayerTurnState")
		return
	if  not turn_start :
		return
	EnemyActionManage.try_perform_ai_action()
	

func on_state_exit() -> void:
	TurnManager.player_turn_started.disconnect(on_player_turn_started)
	turn_start = false
	
		
func on_player_turn_started() -> void:
	go_to_next_turn = true
	
