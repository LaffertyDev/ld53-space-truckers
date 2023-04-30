extends CharacterBody2D

var player_name: String
const SPEED = 5.0

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
	velocity += %ShipInputSync.direction
	move_and_slide()
