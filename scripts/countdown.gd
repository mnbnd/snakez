# SimpleCountdown.gd
extends CanvasLayer

@onready var countdown_label = $Label # Assuming you have a Label node as a child

var countdown_time = 3.0
var counting_down = false

func _ready():
	# Hide the label initially
	countdown_label.hide()

func start_countdown():
	if not counting_down:
		counting_down = true
		countdown_time = 3.0 # Reset time
		countdown_label.text = "3"
		countdown_label.show()
		get_tree().paused = true # Pause the game

func _process(delta):
	if counting_down:
		countdown_time -= delta
		if countdown_time > 2.0:
			countdown_label.text = "3"
		elif countdown_time > 1.0:
			countdown_label.text = "2"
		elif countdown_time > 0.0:
			countdown_label.text = "1"
		else:
			countdown_label.text = "GO!" # Or hide the label
			counting_down = false
			get_tree().paused = false # Unpause the game
			# Emit a signal or call a function here to notify other nodes the countdown is over
			print("Countdown Finished!")
			# You might want to hide the "GO!" text after a short delay
			# For simplicity, we'll just leave it for now.

# Example of how to start the countdown (you would call this from your game manager or start button)
func _input(event):
	if event.is_action_pressed("ui_accept") and not counting_down:
		start_countdown()
