extends BaseState

func on_state_enter() -> void:
	print(">>> Black (xiangqi) turn")
	TurnManager.start_black_turn()

	if Engine.has_singleton("ChessAiManager") or typeof(ChessAiManager) != TYPE_NIL:
		ChessAiManager.perform_ai_turn(false, func ():
			# 黑方执行完后回到下一轮意图
			change_state("EnemyIntentState")
		)
	else:
		print("⚠️ ChessAIManager 未挂载")
		change_state("EnemyIntentState")
