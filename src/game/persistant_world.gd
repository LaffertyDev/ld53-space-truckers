extends Node2D

const player_scene = preload("res://src/game/player/player.tscn")
const ship_scene = preload("res://src/game/ships/ship.tscn")

const networked_port = 4242
const actual_server_addr = "159.223.132.235"

func _ready():
	if DisplayServer.get_name() == "headless":
		start_server()
	else:
		start_client()

func start_server():
	print("Starting Server!")
	var peer = ENetMultiplayerPeer.new()
	multiplayer.connected_to_server.connect(self._on_connected_to_server)
	multiplayer.server_disconnected.connect(self._on_server_disconnect)
	multiplayer.peer_connected.connect(self.create_player)
	multiplayer.peer_disconnected.connect(self.destroy_player)
	peer.create_server(networked_port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return	
	multiplayer.set_multiplayer_peer(peer)
	
	print("Server Started Successfully")
		
func start_client():
	print("Starting Client!")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(actual_server_addr, networked_port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start client!")
		return	
	multiplayer.set_multiplayer_peer(peer)
	multiplayer.connected_to_server.connect(self._on_connected_to_server)
	multiplayer.server_disconnected.connect(self._on_server_disconnect)
	multiplayer.peer_connected.connect(self._on_client_peer_connected)
	print("Client Started Successfully")
	

func create_player(id):
	var ship = ship_scene.instantiate()
	ship.player_mp_id = id
	ship.position = Vector2(randi() % 500, randi() % 500)
	ship.name = str(id)
	%player_ships_list.add_child(ship, true)
	
	var p = player_scene.instantiate()
	p.player_mp_id = id
	p.player_name = "Player %d" % id
	p.name = str(id)
	%networked_player_list.add_child(p, true)

func destroy_player(id):
	# Delete this peer's data.
	# fires from timeouts, etc..
	# spawners should handle this no problem
	%networked_player_list.get_node(str(id)).queue_free()
	%player_ships_list.get_node(str(id)).queue_free()

func _on_multiplayer_spawner_spawned(_node):
	print("player spawned (called on Client)")

func _on_multiplayer_spawner_despawned(_node):
	print("player despawned (called on Client)")

func _on_connected_to_server():
	print("This app has connected to the server")
	
func _on_connected_to_peer():
	print("I have connected to a peer")

func _on_server_disconnect():
	print("Server has disconnected")

func _on_client_peer_connected(id):
	print("peer connected, the peer is %s I am %s" % [id, multiplayer.get_unique_id()])
	#print("This does not work how Ie xpect")
