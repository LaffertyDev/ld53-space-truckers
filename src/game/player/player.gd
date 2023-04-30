extends Node2D

var player_name: String

var my_ship = null

@export var player_mp_id = -1 :
	get:
		return player_mp_id
	set(val):
		player_mp_id = val
		
@export var player_score = 0 :
	get:
		return player_score
	set(val):
		player_score = val
		# this is inefficient and updated on every packet drop
		%score.text = "Current Score: %s" % val

@export var current_delivery_destination: String :
	get:
		return current_delivery_destination
	set(val):
		# this is inefficient and updated on every packet drop
		if current_delivery_destination != val:
			current_delivery_destination = val
			update_destination()

func _ready():
	add_to_group("players")
	var is_current_player = player_mp_id == multiplayer.get_unique_id()
	%player_camera.enabled = is_current_player
	%destinations.visible = is_current_player
	set_process(is_current_player)
	
	var ships = get_tree().get_nodes_in_group("ships")
	for ship in ships:
		if ship.is_in_group("nodes_by_%s" % player_mp_id):
			my_ship = ship
			if current_delivery_destination != null:
				update_destination()

func _process(_delta):
	if my_ship != null:
		%player_camera.position = my_ship.position

func update_destination():
	%destinations.text = "Current Destination: %s" % current_delivery_destination
	if my_ship != null && self.is_inside_tree():
		var stations = get_tree().get_nodes_in_group("stations")
		for station in stations:
			if station.station_uuid == current_delivery_destination:
				my_ship.update_destination(station.global_position)
