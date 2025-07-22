extends MarginContainer

@onready var end_turn_button: Button = $EndTurnButton
@onready var turn_label: Label = $TurnLabel


func _ready() -> void:
	end_turn_button.pressed.connect(on_end_turn_button_pressed)
	TurnManager.player_turn_started.connect(on_player_turn_started)
	TurnManager.enemy_turn_started.connect(on_enemy_turn_started)
	
	
	
func on_end_turn_button_pressed() ->void:
	TurnManager.start_enemy_turn()
	
func on_player_turn_started() ->void:
	turn_label.text = "Player Turn"
	
func on_enemy_turn_started() ->void:
	turn_label.text = "Enemy Turn"
