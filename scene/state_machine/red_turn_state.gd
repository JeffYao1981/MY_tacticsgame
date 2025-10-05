extends BaseState

func on_state_enter() -> void:
	print(">>> Red (xiangqi) turn")
	TurnManager.红棋行动回合发射信号()

	ChessAiManager.perform_ai_turn(true, func ():
			change_state("BlackTurnState"))
		
		
	
