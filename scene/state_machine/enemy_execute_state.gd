extends BaseState


func on_state_enter() -> void:
	
	TurnManager.start_enemy_execute()
	
	EnemyActionManage.execute_intents(func ():
		change_state("RedTurnState")
	)
