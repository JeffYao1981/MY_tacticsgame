extends MarginContainer


@onready var button: Button = $PanelContainer/MarginContainer/VBoxContainer/Button
@onready var label: Label = $PanelContainer/MarginContainer/VBoxContainer/Label



var game_finished:bool = false

func _ready() -> void:
	GameManager.game_win.connect(on_game_win)
	GameManager.game_over.connect(on_game_over)
	button.pressed.connect(on_exit_button_pressed)
	
	visible = false
	
func _input(event: InputEvent) -> void:
	if game_finished:
		return
	if event.is_action_pressed("escape"):
		label.text = "Return to Menu"
		visible = !visible
	
func on_game_win() ->void:
	label.text = "Game Win"
	visible = true
	game_finished = true
	
	
func on_game_over() ->void:
	label.text = "Game Over"
	visible = true
	game_finished = true
	
func on_exit_button_pressed() ->void:
	GameManager.exit_game()
	get_tree().change_scene_to_file("res://scene/start_menu_scene.tscn")
	
	
	
	
	
	
	
	
	
