extends PanelContainer

@onready var start_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/StartButton
@onready var back_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/BackButton
@onready var unit_card_container: VBoxContainer = $MarginContainer/VBoxContainer/UnitsInfoContainer/UnitSelection/UnitCardContainer
@onready var unit_icon: TextureRect = $MarginContainer/VBoxContainer/UnitsInfoContainer/UnitInfo/MarginContainer/VBoxContainer/IconName/UnitIcon
@onready var unit_name: Label = $MarginContainer/VBoxContainer/UnitsInfoContainer/UnitInfo/MarginContainer/VBoxContainer/IconName/UnitName
@onready var unit_description: Label = $MarginContainer/VBoxContainer/UnitsInfoContainer/UnitInfo/MarginContainer/VBoxContainer/UnitDescription

@export var unit_card_ui_scene: PackedScene
@export var unit_resources:Array[UnitResource]#手动添加的列表，列表的内容为：archer\knight\wizard_unit_resource.tres
@onready var level_selection_ui: PanelContainer = $"../LevelSelectionUI"


func _ready() -> void:
	AudioManager.register_button(start_button)
	AudioManager.register_button(back_button)
	start_button.pressed.connect(on_start_button_pressed)#链接start_button按钮按下信号
	back_button.pressed.connect(on_back_button_pressed)#链接back_button按钮按下信号
	for unit_resource in unit_resources:#遍历手动指定的单位资源对象
		var unit_card_ui:UnitCardUI = unit_card_ui_scene.instantiate()#为该单位资源创建一个角色选择按钮
		unit_card_container.add_child(unit_card_ui)#将这个按钮添为unit_card_container节点的子节点
		unit_card_ui.set_up(unit_resource)#运行这个按钮下的setup方法
		unit_card_ui.unit_havered.connect(on_unit_havered)#连接这个按钮下的鼠标悬停信号
		unit_card_ui.unit_selected.connect(on_unit_selected)#连接这个按钮下的点选信号
		unit_card_ui.unit_deselected.connect(on_unit_deselected)#连接这个按钮下的取消选择信号

func on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.selected_level_resource.level_scene)
	
func on_back_button_pressed() -> void:
	visible = false
	level_selection_ui.visible = true
	
func on_unit_havered(unit_resource:UnitResource) -> void:
	unit_icon.texture = unit_resource.unit_icon
	unit_name.text = unit_resource.unit_name
	unit_description.text = unit_resource.unit_description

func on_unit_selected(unit_resource:UnitResource) -> void:
	GameManager.selected_player_resources.append(unit_resource)
	
func on_unit_deselected(unit_resource:UnitResource) ->void:
	GameManager.selected_player_resources.erase(unit_resource)
