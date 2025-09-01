extends Node


var saved_data:SaveData

func save_data(level_name:String) ->void:
	if saved_data == null:
		saved_data = SaveData.new()
	if not saved_data.level_completed.has(level_name):
		saved_data.level_completed.append(level_name)
	
	ResourceSaver.save(saved_data,"user://save_data.tres")
	
func load_data() -> SaveData:
	if not ResourceLoader.exists("user://save_data.tres"):
		return null
	saved_data = ResourceLoader.load("user://save_data.tres") as SaveData
	return saved_data
