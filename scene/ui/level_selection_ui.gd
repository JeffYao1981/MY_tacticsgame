extends PanelContainer

@onready var unit_selection_ui: PanelContainer = $"../UnitSelectionUI"

@onready var level_card_container: GridContainer = $MarginContainer/VBoxContainer/LevelCardContainer


@export var level_card_ui_scene:PackedScene
@export var level_resources:Array[LevelResource]


func _ready() -> void:
	var save_data:SaveData = SaveManager.load_data()
	for level_resource in level_resources:
		var level_card_ui:LevelCardUI = level_card_ui_scene.instantiate()
		level_card_container.add_child(level_card_ui)
		level_card_ui.set_up(level_resource)
		level_card_ui.level_selected.connect(on_level_selected)
		if save_data and save_data.level_completed.has(level_resource.level_name):
			level_card_ui.completion_indentifier.visible = true
			

func on_level_selected(level_resource:LevelResource)->void:
	GameManager.selected_level_resource = level_resource
	visible = false
	unit_selection_ui.visible = true
	
