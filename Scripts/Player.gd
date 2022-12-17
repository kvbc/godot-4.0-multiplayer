extends CharacterBody2D

const SPEED = 200
var client_data = ALRPC.CreatePlayerClientToServerData(Vector2.ZERO)
var peer_id: int
var is_master: bool = true
var is_multiplayer_initialized = false

func _unhandled_key_input (event):
	if is_master:
		if event is InputEventKey:
			if event.pressed:
				match event.keycode:
					KEY_W: client_data.dir.y = Vector2.UP.y
					KEY_S: client_data.dir.y = Vector2.DOWN.y
					KEY_A: client_data.dir.x = Vector2.LEFT.x
					KEY_D: client_data.dir.x = Vector2.RIGHT.x

func _physics_process (delta):
	if ALWorld.IsServer():
		velocity = client_data.dir * SPEED
		move_and_slide()
		
	if ALWorld.IsMultiplayer():
		if ALWorld.IsServer():
			ALWorld.rpc(
				"MultiplayerSendPlayerServerToClientData",
				peer_id,
				ALRPC.CreatePlayerServerToClientData(position, client_data)
			)
		elif is_master:
			ALWorld.rpc_id(
				ALWorld.GetServerPeerID(),
				"MultiplayerSendPlayerClientToServerData",
				peer_id,
				client_data
			)

func _process (delta):
	if is_master:
		if not Input.is_key_pressed(KEY_W):
			if client_data.dir.y == Vector2.UP.y:
				client_data.dir.y = 0
		if not Input.is_key_pressed(KEY_S):
			if client_data.dir.y == Vector2.DOWN.y:
				client_data.dir.y = 0
		if not Input.is_key_pressed(KEY_A):
			if client_data.dir.x == Vector2.LEFT.x:
				client_data.dir.x = 0
		if not Input.is_key_pressed(KEY_D):
			if client_data.dir.x == Vector2.RIGHT.x:
				client_data.dir.x = 0
	
	var animation
	if client_data.dir == Vector2.ZERO:
		animation = "idle"
	else:
		animation = "walk"
	if $AnimatedSprite2D.animation != animation:
		$AnimatedSprite2D.play(animation)
		
	if client_data.dir.x != 0:
		$AnimatedSprite2D.flip_h = (client_data.dir.x < 0)

#
#
# PUBLIC
#
#

func InitializeMultiplayer (_peer_id : int, _is_master : bool) -> void:
	assert(not is_multiplayer_initialized)
	peer_id = _peer_id
	is_master = _is_master
	is_multiplayer_initialized = true

# Handled on the server
func MultiplayerHandleClientToServerData (_client_data):
	client_data = _client_data

# Handled on the client
func MultiplayerHandleServerToClientData (server_data):
	# position = position.lerp(server_data.position, 0.5)
	position = server_data.position
	# Puppet
	if not is_master:
		client_data = server_data.client_data
