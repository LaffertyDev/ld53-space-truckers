extends Node2D

var player_name: String

var my_ship = null

@export var player_mp_id = -1 :
	get:
		return player_mp_id
	set(val):
		player_mp_id = val

func _ready():
	print(player_mp_id)
	print("Player spawned. Name: %s, position: %s" % [player_name, position])
	var is_current_player = player_mp_id == multiplayer.get_unique_id()
	%player_camera.enabled = is_current_player
	set_process(is_current_player)
	
	var ships = get_tree().get_nodes_in_group("ships")
	print(ships.size())
	for ship in ships:
		print("nodes_by_%s" % player_mp_id)
		if ship.is_in_group("nodes_by_%s" % player_mp_id):
			my_ship = ship

func _process(_delta):
	if my_ship != null:
		%player_camera.position = my_ship.position
