extends Node

#
#
# PUBLIC
#
#

func CreatePlayerClientToServerData (dir : Vector2):
	return {
		"dir": dir
	}
			
func CreatePlayerServerToClientData (position : Vector2, client_data):
	return {
		"position": position,
		"client_data": client_data
	}
