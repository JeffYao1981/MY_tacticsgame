extends BaseState


func on_state_enter() -> void:
	
	TurnManager.敌人攻击回合发射信号()
	
	EnemyActionManage.execute_intents(func ():
		change_state("RedTurnState")
	)


func on_state_exit() ->void:#退出时执行
	print("退出敌人攻击回合，执行清理")
	EnemyIntentVisualizer.clear_all()
