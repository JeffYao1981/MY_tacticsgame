extends BaseState

func on_state_enter() -> void:
	print(">>> Black (xiangqi) turn")
	TurnManager.黑棋行动回合发射信号()

	ChessAiManager.perform_ai_turn(false, func ():
			# 黑方执行完后回到下一轮意图
			change_state("EnemyIntentState"))
