extends Node
class_name BaseState

signal state_changed(state_name:String)

@export var state_name: String


func on_state_enter() -> void:#进入时执行
	pass
	
func on_state_frame_update(delta:float) ->void:#每帧执行
	pass
	
func on_state_physics_update(delta:float) ->void:#每隔一段时间执行
	pass
	
func on_state_exit() ->void:#退出时执行
	pass
	
