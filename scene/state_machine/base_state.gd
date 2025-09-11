extends Node
class_name BaseState

signal state_changed(state_name:String)
@export var turn_movie: PackedScene
@export var state_name: String

# 给状态持有对 state machine 的引用（在 StateMachine._ready 中会注入）
var state_machine: StateMachine = null

var turn_start:bool = false
var go_to_next_turn:bool = false

func on_state_movie() ->void:
	
	print("来了来了！")
	go_to_next_turn = false
	var start_movie = turn_movie.instantiate()
	start_movie.text = state_name
	get_tree().current_scene.add_child(start_movie)
	await start_movie.animation_player.animation_finished
	
	turn_start = true
	on_state_enter()


func on_state_enter() -> void:#进入时执行
	pass
	
func on_state_frame_update(delta:float) ->void:#每帧执行
	pass
	
func on_state_physics_update(delta:float) ->void:#每隔一段时间执行
	pass
	
func on_state_exit() ->void:#退出时执行
	pass
	
# 便捷接口：状态内调用 change_state("NextStateName")
func change_state(new_state:String) -> void:
	if state_machine != null:
		state_machine.change_state(new_state)
	else:
		# 退回到 signal 模式（兼容）
		state_changed.emit(new_state)
