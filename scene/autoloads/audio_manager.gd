extends Node

@onready var music_stream_player: AudioStreamPlayer = $MusicStreamPlayer
@onready var click_sound_player: AudioStreamPlayer = $ClickSoundPlayer


func _ready() -> void:
	music_stream_player.finished.connect(on_music_finished)
	
	
func register_button(button:Button) ->void:
	button.pressed.connect(on_button_pressed)

	
func on_music_finished()-> void:
	music_stream_player.play()

func on_button_pressed()-> void:
	click_sound_player.play()
