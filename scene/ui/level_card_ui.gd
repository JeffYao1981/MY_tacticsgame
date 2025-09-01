extends Button

class_name LevelCardUI


@onready var completion_indentifier: TextureRect = $CompletionIndentifier

signal level_selected(level_resource:LevelResource)

var level_resource:LevelResource


func _ready() -> void:
	AudioManager.register_button(self)
	pressed.connect(on_button_pressed)


func set_up(level_resource:LevelResource) -> void:
	self.level_resource = level_resource
	text = level_resource.level_name

func on_button_pressed()-> void:
	level_selected.emit(level_resource)
	
