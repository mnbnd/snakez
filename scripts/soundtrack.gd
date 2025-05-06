extends Node

var player: AudioStreamPlayer = null

func _ready():
	if not player:
		player = AudioStreamPlayer.new()
		var stream = preload("res://assets/snakezsoundtrack.ogg")
		if stream is AudioStream:
			stream.loop = true
		player.stream = stream
		player.autoplay = true
		player.volume_db = -12
		add_child(player)
		player.play()
