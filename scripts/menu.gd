extends Control

@onready var cam_speed_input = $Panel2/cam_speed

@onready var start_button := $Play

func _ready():
	#fill with default value
	cam_speed_input.text = str(Settings2.cam_lerp_speed)
	start_button.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	#get value from text box
	var text_val = cam_speed_input.text.strip_edges()
	var cam_speed = text_val.to_float()
	
	Settings2.cam_lerp_speed = cam_speed

	get_tree().change_scene_to_file("res://Main.tscn")
	
func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://credits.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
