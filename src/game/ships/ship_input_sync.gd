extends MultiplayerSynchronizer

@export var is_thrusting := false
@export var ship_rotation := 0
@export var direction := Vector2()

func _ready():
	# only process locally for the local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _process(_delta):
	is_thrusting = Input.is_action_pressed("ship_thrust")
	
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
		print("ui left")
	elif Input.is_action_pressed("ui_right"):
		direction.x = 1
	else:
		direction.x = 0

	if Input.is_action_pressed("ui_up"):
		direction.y = -1
	elif Input.is_action_pressed("ui_down"):
		direction.y = 1
	else:
		direction.y = 0
