extends Node2D

const SINGLEPLAYER_PEER_ID = 0

var singleplayer_player
var multiplayer_players := {}

func create_player ():
	var player = preload("res://Scenes/Player.tscn").instantiate()
	$Players.add_child(player)
	return player

func add_player_to_multiplayer (player, peer_id : int, is_master : bool) -> void:
	assert(IsMultiplayer())
	player.InitializeMultiplayer(peer_id, is_master)
	assert(not multiplayer_players.has(peer_id))
	multiplayer_players[peer_id] = player

func get_multiplayer_player (peer_id : int):
	assert(IsMultiplayer())
	return multiplayer_players[peer_id]

func _ready ():
	singleplayer_player = create_player()
	
#
#
# PUBLIC
#
#

func IsMultiplayer () -> bool:
	return not multiplayer.multiplayer_peer is OfflineMultiplayerPeer

func GetServerPeerID () -> int:
	assert(IsMultiplayer())
	return get_multiplayer_authority()

func GetPeerID () -> int:
	assert(IsMultiplayer())
	return multiplayer.multiplayer_peer.get_unique_id()

func IsServer () -> bool:
	return (not IsMultiplayer()) or multiplayer.is_server()

@rpc(any_peer)
func MultiplayerSendPlayerServerToClientData (peer_id : int, server_data) -> void:
	assert(IsMultiplayer())
	get_multiplayer_player(peer_id).MultiplayerHandleServerToClientData(server_data)
@rpc(any_peer)
func MultiplayerSendPlayerClientToServerData (client_peer_id : int, client_data) -> void:
	assert(IsMultiplayer())
	get_multiplayer_player(client_peer_id).MultiplayerHandleClientToServerData(client_data)

func InitializeMultiplayerServer (port : int) -> void:
	assert(not IsMultiplayer())
	print("[SERVER] Creating server on port: " + str(port))
	
	multiplayer.peer_connected.connect(func (peer_id : int):
		add_player_to_multiplayer(create_player(), peer_id, false)
		print("[SERVER] peer ID %d connected" % peer_id)	
	)
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	
	add_player_to_multiplayer(singleplayer_player, GetServerPeerID(), true)

func InitializeMultiplayerClient (ip:String, port:int) -> void:
	assert(not IsMultiplayer())
	print("[CLIENT] Joining server %s:%s" % [ip,port])
	
	multiplayer.peer_connected.connect(func (peer_id : int):
		var is_server = (peer_id == GetServerPeerID())
		print("[CLIENT] replicating peer ID %s, server = %s" % [peer_id, is_server])
		add_player_to_multiplayer(create_player(), peer_id, false)
	)
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	
	add_player_to_multiplayer(singleplayer_player, GetPeerID(), true)
	
