extends Label

@export_node_path  var storm_path: NodePath
var zone       : Node
var time_left        : float

func _ready() -> void:
	# find the storm node and read its delay_time
	zone = get_node(storm_path)
	time_left  = zone.delay_time
	# optional: show initial value immediately
	text = str(int(time_left)) + "s"

func _process(delta: float) -> void:
	if time_left > 0.0:
		time_left = max(time_left - delta, 0.0)
		# display whole seconds remaining
		text = str(int(ceil(time_left))) + "s"
	else:
		text = "Storm Incoming!"
		set_process(false)
