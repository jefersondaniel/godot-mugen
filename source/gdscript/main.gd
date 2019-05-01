extends Node

var Player = load('res://source/gdscript/entities/player.gd')

func _init():
	var player1 = Player.new()
	player1.load_data('res://data/chars/kfm/kfm.def')
	player1.position = Vector2(300, 300)
	self.add_child(player1)
