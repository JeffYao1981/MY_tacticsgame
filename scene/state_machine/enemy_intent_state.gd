extends BaseState

func on_state_enter() -> void:
	
	print(">>> Enemy Intent Phase")
	TurnManager.敌人意图回合发射信号()
	
	EnemyActionManage.collect_intents()  # 这里执行敌人的“移动到位”和预测展示
	await get_tree().create_timer(1.5).timeout
	change_state("PlayerTurnState")




	
	
	
