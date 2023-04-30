extends CharacterBody2D

var player_name: String
const MAX_SPEED = 1500.0
const ACCELERATION_PER_SECOND = 600 #980 is default gravity
const SHIP_TRANSLATION_SPEED = 400
const CORRECTION_SPEED = 300

@export var my_velocity = self.velocity

@export var player_mp_id = -1 :
	get:
		return player_mp_id
	set(val):
		player_mp_id = val
		$ShipInputSync.set_multiplayer_authority(player_mp_id)
		%velocity_vector.visible = true
		%acceleration_vector.visible = true

func _ready():
	#set_physics_process(multiplayer.is_server())
	add_to_group("ships")
	add_to_group("nodes_by_%s" % player_mp_id)
	pass

func _physics_process(_delta):
	velocity = my_velocity
	rotation = deg_to_rad(%ShipInputSync.ship_rotation_degrees)
	%debug_label.text = "rd: %s, vx: %s, vy: %s" % [int(rad_to_deg(rotation)), velocity.x, velocity.y]
	
	var facing_vector = Vector2.from_angle(rotation)
	var angle_to_velocity = facing_vector.angle_to(velocity)
	%velocity_vector.rotation = angle_to_velocity + 1.57
	%velocity_vector.position = Vector2(1, 0).rotated(angle_to_velocity) * 180

	# if all stop, accelerate all pull to zero
	var thrust_acceleration_normalized = ACCELERATION_PER_SECOND * _delta
	var thrust_acceleration_vector = Vector2(thrust_acceleration_normalized, 0).rotated(rotation)
	if %ShipInputSync.is_thrusting_forward:
		thrust_acceleration_vector *= 1
	elif %ShipInputSync.is_thrusting_backward:
		thrust_acceleration_vector *= -1
	else:
		thrust_acceleration_vector *= 0
	
	var translation_acceleration_normalized = SHIP_TRANSLATION_SPEED * _delta
	var translation_acceleration_vector = Vector2(SHIP_TRANSLATION_SPEED * _delta * cos(rotation - 1.57), SHIP_TRANSLATION_SPEED * _delta * sin(rotation - 1.57))
	if %ShipInputSync.is_translating_left:
		translation_acceleration_vector *= 1
	elif %ShipInputSync.is_translating_right:
		translation_acceleration_vector *= -1
	else:
		# reduce sideways motion aggressively
		translation_acceleration_vector.x = 0
		translation_acceleration_vector.y = 0
	
	if thrust_acceleration_vector.is_zero_approx():
		var correction_speed_normalized = velocity.abs().length() * 0.75 * _delta
		var angle_to_velocity_degrees = rad_to_deg(angle_to_velocity)
		if angle_to_velocity_degrees > 0 && angle_to_velocity_degrees < 90:
			thrust_acceleration_vector = facing_vector.orthogonal() * correction_speed_normalized
		elif angle_to_velocity_degrees < 0 && angle_to_velocity_degrees > -90:
			thrust_acceleration_vector = facing_vector.orthogonal() * correction_speed_normalized * -1
		elif angle_to_velocity_degrees < -90 || angle_to_velocity_degrees > 90:
			thrust_acceleration_vector = velocity.normalized() * correction_speed_normalized * -1
		else:
			# we're dead-on, so just slow by an amount
			thrust_acceleration_vector = velocity * -1 * _delta
			
		if thrust_acceleration_vector.length() < 0.1:
			thrust_acceleration_vector *= 0
	
	var acceleration_total = thrust_acceleration_vector + translation_acceleration_vector
	if %ShipInputSync.all_stop:
		acceleration_total = velocity * _delta * -3.5 # bleed 25% of speed every second
		if (acceleration_total.abs().length() < 1.5):
			acceleration_total = velocity * _delta * -8
	
	velocity += acceleration_total
	%acceleration_vector.rotation = acceleration_total.angle() + 1.57 - rotation
	%acceleration_vector.position = acceleration_total.normalized().rotated(-rotation) * 120
	
	# min and max
	if velocity.is_zero_approx():
		velocity.x = 0
		velocity.y = 0
	velocity = velocity.limit_length(MAX_SPEED)
	my_velocity = velocity
	move_and_slide()
