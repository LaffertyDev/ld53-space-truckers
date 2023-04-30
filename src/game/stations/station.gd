extends Node2D

@export var station_uuid: String

func _ready():
	add_to_group("stations")
	
func get_random_delivery_destination(except: String):
	var stations = get_tree().get_nodes_in_group("stations")
	var destination = stations[randi() % stations.size()]
	print(destination.name)
	if destination.station_uuid == except:
		return get_random_delivery_destination(except)
	return destination.station_uuid


func _on_landing_pad_right_body_entered(body):
	print("hit landing pad")
	var player_id = body.player_mp_id
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.player_mp_id == player_id:
			if player.current_delivery_destination == station_uuid:
				print("hit your current landing pad!")
				player.player_score += 1
				player.current_delivery_destination = get_random_delivery_destination(player.current_delivery_destination)

