extends CanvasLayer

@export var start_time_sec: float = 45.0  # seconds to count down from
var time_left: float

@onready var timer_label: Label = $Label
@onready var storm_closing_sound: AudioStreamPlayer = $storm_sfx

func _ready() -> void:
	time_left = start_time_sec
	_update_label()

func _process(delta: float) -> void:
	if time_left > 0.0:
		time_left = max(time_left - delta, 0.0)
		_update_label()
		if time_left == 0.0:
			_on_time_up()

func _update_label() -> void:
	var total = int(time_left)
	var mins = total / 60
	var secs = total % 60

	timer_label.text = "The storm is closing in: %02d:%02d" % [mins, secs]

func _on_time_up() -> void:
	storm_closing_sound.play()
	timer_label.text = "THE STORM IS COMING!"
