extends BaseState

func on_state_enter() -> void:
	print(">>> Red (xiangqi) turn")
	TurnManager.start_red_turn()

	# 使用 ChessAIManager 进行AI操作（红方）
	if Engine.has_singleton("ChessAiManager") or typeof(ChessAiManager) != TYPE_NIL:
		ChessAiManager.perform_ai_turn(true, func ():
			change_state("BlackTurnState")
		)
	else:
		print("⚠️ ChessAIManager 未挂载")
		change_state("BlackTurnState")
