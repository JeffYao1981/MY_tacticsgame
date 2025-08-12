extends Node
class_name BaseState

signal state_changed(state_name:String)
@export var turn_movie: PackedScene
@export var state_name: String
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
	
