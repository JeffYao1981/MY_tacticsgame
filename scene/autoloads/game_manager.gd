extends Node

signal  game_over()
signal  game_win()

var selected_level_resource:LevelResource
var selected_player_resources:Array[UnitResource]
var maximum_unit_count:int = 3

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

func spawn_player_units() -> void: #生成玩家角色
	var spawn_position_idx: int = 0	#索引
	var spawn_positions:Array[Node2D] = get_tree().current_scene.player_spawn_positions	#将当前场景下指定的角色出生点列表赋值过来
	for unit_resources:UnitResource in selected_player_resources:	#在选择好的角色资源列表中遍历
		if spawn_position_idx < spawn_positions.size():		#索引（0开始）最大值小于出生点数量（1开始）
			var unit:Unit = unit_resources.unit_scene.instantiate() #通过角色资源列表中的角色场景对象来创建角色对象
			get_tree().current_scene.add_child(unit)	#当前场景下新增子节点——角色场景对象？
			unit.global_position = spawn_positions[spawn_position_idx].global_position	#角色的位置等于指定位置列表[索引]
			spawn_position_idx += 1		#索引值加一
		
func on_unit_died(unit:Unit) -> void:
	if unit.is_enemy and enemy_units.is_empty():
		print("GameWin")
		game_win.emit()
	if not unit.is_enemy and player_units.is_empty():
		print("GameOver")
		game_over.emit()
		
func exit_game() -> void:
	selected_player_resources.clear()
	player_units.clear()
	enemy_units.clear()
	GridManager.nav_layer = null
	GridManager.visual_layer = null
	PlayerActionManager.is_performing_action = false
	PlayerActionManager.selected_action = null
	PlayerActionManager.selected_unit = null
	PlayerActionManager.range_box_switch = false
	EnemyActionManage.is_performing_action = false
	
	
	
	
	
	
	
