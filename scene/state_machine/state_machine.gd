extends Node
class_name StateMachine


@export var starting_state:BaseState

var states: Array[BaseState]
var current_state:BaseState

var is_launched: bool = false #状态机是否启动


func _ready() -> void:
	for state:BaseState in get_children():
		states.append(state)
		state.state_changed.connect(on_state_changed)
		
func launch_state_machine() -> void:
	is_launched = true
	current_state = starting_state	
	current_state.on_state_enter()

func _process(delta: float) -> void:
	if is_launched:
		current_state.on_state_frame_update(delta)
		
func _physics_process(delta: float) -> void:
	if is_launched:
		current_state.on_state_physics_update(delta)
		
func on_state_changed(state_name:String) -> void:
	var new_state:BaseState = get_state(state_name)
	if new_state != null:
		current_state.on_state_exit()
		current_state = new_state
		current_state.on_state_enter()
	
func get_state(state_name:String) -> BaseState:
	for state in states:
		if state.state_name == state_name:
			return state
	return null
	
