extends Node
class_name StateMachine



# 手动指定从谁的回合开始
@export var starting_state:BaseState 

var states: Dictionary = {}
var current_state:BaseState
var is_launched: bool = false #状态机是否启动


func _ready() -> void:
	TurnManager.state_machine = self
	# 收集所有子节点作为状态
	for child in get_children():
		# 只要有 on_state_enter 就认为是状态
		if child.has_method("on_state_enter"):
			#往states: Dictionary中赋值
			states[child.state_name] = child
			# 给子节点state的state_macthine赋值
			child.state_machine = self
			# 为子节点的state_changed信号做链接，上面赋值的其实就够了
			if child.has_signal("state_changed"):
				child.state_changed.connect(on_state_changed)
		
func launch_state_machine() -> void:
	is_launched = true
	#current_state = starting_state
	if starting_state != null:
		change_state(starting_state.state_name)
	else:
		# 默认从 EnemyIntentState 开始（若不存在则尝试第一个）
		var default_name := get_next_state("")
		change_state(default_name)
	
	

func _process(delta: float) -> void:
	if is_launched and current_state != null:
		current_state.on_state_frame_update(delta)
		
func _physics_process(delta: float) -> void:
	if is_launched and current_state != null:
		current_state.on_state_physics_update(delta)
		
		
		
####################################################################################
func change_state(new_state_name:String) -> void:
	if not states.has(new_state_name):
		push_warning("StateMachine: state not found: %s" % new_state_name)
		return

	if current_state != null:
		current_state.on_state_exit()

	current_state = states[new_state_name]
	
	#current_state.on_state_movie()
	
	current_state.on_state_movie()	
####################################################################################	









func on_state_changed(state_name:String) -> void:
	change_state(state_name)
	
func get_state(state_name:String) -> BaseState:
	for state in states:
		if state.state_name == state_name:
			return state
	return null

func get_next_state(state_name:String) -> String:
	var order := [
		"EnemyIntentState",
		"PlayerTurnState",
		"EnemyExecuteState",
		"RedTurnState",
		"BlackTurnState"
	]
	var idx := order.find(state_name)
	if idx == -1:
		return order[0]
	return order[(idx + 1) % order.size()]	
	
