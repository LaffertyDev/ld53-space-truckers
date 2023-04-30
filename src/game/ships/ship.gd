extends CharacterBody2D

var player_name: String
const MAX_SPEED = 1500.0
const ACCELERATION_PER_SECOND = 600 #980 is default gravity

@export var my_velocity = self.velocity

@export var player_mp_id = -1 :
	get:
		return player_mp_id
	set(val):
		player_mp_id = val
		$ShipInputSync.set_multiplayer_authority(player_mp_id)

func _ready():
	#set_physics_process(multiplayer.is_server())
	print(player_mp_id)
	add_to_group("ships")
	add_to_group("nodes_by_%s" % player_mp_id)
	print(player_mp_id)
	pass

func _physics_process(_delta):
	rotation = deg_to_rad(%ShipInputSync.ship_rotation_degrees)
	%debug_label.text = "rd: %s, vx: %s, vy: %s" % [int(rad_to_deg(rotation)), velocity.x, velocity.y]
	
	# compute velocity direction from my rotation
	var sluggish_deceleration_amount = 0.5
	var acceleration_normalized = ACCELERATION_PER_SECOND * _delta
	var accel_vec = Vector2(acceleration_normalized * cos(rotation), acceleration_normalized * sin(rotation))
	if %ShipInputSync.is_thrusting_forward:
		velocity += accel_vec
		sluggish_deceleration_amount = 0
	elif %ShipInputSync.is_thrusting_backward:
		velocity -= accel_vec
		sluggish_deceleration_amount = 0
	elif %ShipInputSync.all_stop:
		sluggish_deceleration_amount = 4
	
	if sluggish_deceleration_amount > 0:
		if velocity.length() > 1:
			var minimum_loss = velocity.normalized() * 100 * _delta
			var real_loss = velocity * (_delta * sluggish_deceleration_amount)
			if (minimum_loss.length() > real_loss.length()):
				velocity -= minimum_loss
			else:
				velocity -= real_loss
		else:
			velocity.x = 0
			velocity.y = 0
		
	velocity = velocity.limit_length(MAX_SPEED)
	move_and_slide()
