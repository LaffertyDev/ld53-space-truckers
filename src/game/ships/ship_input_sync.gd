extends MultiplayerSynchronizer

@export var is_thrusting_forward := false
@export var is_thrusting_backward := false
@export var ship_rotation_degrees := 0
@export var all_stop := false

func _ready():
	# only process locally for the local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _process(_delta):
	if (Input.is_action_pressed("ship_thrust_forward")):
		is_thrusting_forward = true
		is_thrusting_backward = false
		all_stop = false
	elif (Input.is_action_pressed("ship_thrust_backward")):
		is_thrusting_forward = false
		is_thrusting_backward = true
		all_stop = false
	elif (Input.is_action_pressed("all_stop")):
		is_thrusting_forward = false
		is_thrusting_backward = false
		all_stop = true
	else:
		is_thrusting_forward = false
		is_thrusting_backward = false
		# all_stop is sticky until you accelerate
	
	if (Input.is_action_pressed("rotate_clockwise")):
		ship_rotation_degrees = (ship_rotation_degrees + 1) % 360
	elif (Input.is_action_pressed("rotate_counterclockwise")):
		ship_rotation_degrees = (ship_rotation_degrees - 1) % 360
