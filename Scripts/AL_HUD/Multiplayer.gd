extends VBoxContainer

func get_ip ():
	return $IP.text

func get_port ():
	return int($Port.text)

func on_host_pressed ():
	ALWorld.InitializeMultiplayerServer(get_port())

func on_join_pressed ():
	ALWorld.InitializeMultiplayerClient(get_ip(), get_port())

func _ready ():
	$Host.connect("pressed", on_host_pressed)
	$Join.connect("pressed", on_join_pressed)
