extends Node

# 新的细分回合信号（保留 player_turn_started / enemy_turn_started 兼容）
signal 敌人意图回合
signal 玩家回合
signal 敌人攻击回合
signal 红棋行动
signal 黑棋行动

# 向后兼容
signal enemy_turn_started

@onready var state_machine: StateMachine


func 敌人意图回合发射信号() -> void:
	敌人意图回合.emit()
	

func 玩家回合发射信号() ->void:
	玩家回合.emit()
	
func start_enemy_turn() ->void:
	enemy_turn_started.emit()
	# 同时触发新的 execute 阶段（默认行为）
	敌人攻击回合发射信号()

func 敌人攻击回合发射信号() -> void:
	敌人攻击回合.emit()

func 红棋行动回合发射信号() -> void:
	红棋行动.emit()

func 黑棋行动回合发射信号() -> void:
	黑棋行动.emit()

func is_player_turn() -> bool:
	return state_machine.current_state.state_name == "PlayerTurnState"
