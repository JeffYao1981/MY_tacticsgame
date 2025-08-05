extends Node

signal  game_over()
signal  game_win()

var player_units:Array[Unit]
var enemy_units:Array[Unit]


func register_unit(unit:Unit) -> void:
	if unit.is_enemy:
		enemy_units.append(unit)
	else:
		player_units.append(unit)
	unit.unit_died.connect(on_unit_died)

func unregister_unit(unit:Unit) ->void:
	if unit.is_enemy:
		enemy_units.erase(unit)
	else:
		player_units.erase(unit)
		if PlayerActionManager.selected_unit == unit and not player_units.is_empty():
			PlayerActionManager.set_selected_unit(player_units[0])
		
func on_unit_died(unit:Unit) -> void:
	if unit.is_enemy and enemy_units.is_empty():
		print("GameWin")
		game_win.emit()
	if not unit.is_enemy and player_units.is_empty():
		print("GameOver")
		game_over.emit()
