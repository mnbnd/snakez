extends CanvasLayer

func _ready():
	self.hide()


func victory():
	get_tree().paused = true
	self.show()



func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	



func _on_exit_pressed() -> void:
	get_tree().quit()
