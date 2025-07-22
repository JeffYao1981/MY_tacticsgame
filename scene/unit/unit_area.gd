extends Area2D

signal unit_selected()
var is_mouse_hovered : bool = false

func _ready() -> void:
	mouse_entered.connect(on_mouse_enterde)
	mouse_exited.connect(on_mouse_exited)
	
	
func on_mouse_enterde() ->void:
	is_mouse_hovered = true
	
func on_mouse_exited() -> void:
	is_mouse_hovered = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse_click"):
		if is_mouse_hovered:
			unit_selected.emit()
	
