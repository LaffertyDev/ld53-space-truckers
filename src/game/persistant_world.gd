extends Node2D

const player_scene = preload("res://src/game/player/player.tscn")
const ship_scene = preload("res://src/game/ships/ship.tscn")

const networked_port = 4242
const actual_server_addr = "wss://lafferty.dev:%s" % networked_port

func _ready():
	if OS.is_debug_build():
		if DisplayServer.get_name() == "headless":
			start_server_direct()
		else:
			start_client_direct()
	else:
		if DisplayServer.get_name() == "headless":
			start_server()
		else:
			start_client()
		
func start_server_direct():
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
func start_client_direct():
	print("Starting Client in WS mode!!")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", networked_port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start client!")
		return	
	multiplayer.set_multiplayer_peer(peer)
	multiplayer.connected_to_server.connect(self._on_connected_to_server)
	multiplayer.server_disconnected.connect(self._on_server_disconnect)
	multiplayer.peer_connected.connect(self._on_client_peer_connected)
	print("Client Started Successfully")
	

func start_server():
	print("Starting Server in WS mode!")
	var peer = WebSocketMultiplayerPeer.new()
	multiplayer.connected_to_server.connect(self._on_connected_to_server)
	multiplayer.server_disconnected.connect(self._on_server_disconnect)
	multiplayer.peer_connected.connect(self.create_player)
	multiplayer.peer_disconnected.connect(self.destroy_player)
	var server_certs = load("res://fullchain.crt")
	var server_key = load("res://key.key")
	var server_tls_options = TLSOptions.server(server_key, server_certs)
	peer.create_server(networked_port, "*", server_tls_options)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return	
	multiplayer.set_multiplayer_peer(peer)
	
	print("Server Started Successfully")
		
func start_client():
	print("Starting Client in WS mode!!")
	var peer = WebSocketMultiplayerPeer.new()
	var client_trusted_cas = load("res://fullchain.crt")
	var client_tls_options = TLSOptions.client(client_trusted_cas)
	peer.create_client(actual_server_addr, client_tls_options)
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
