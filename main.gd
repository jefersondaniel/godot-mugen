extends Node

# var sprite_manager = load('res://engine/sprite_manager.gd').new()
# var air_parser = load('./engine/air_parser.gd').new()
var Player = load('./engine/player.gd')

func _init():
	# var bucket = sprite_manager.make_sprite_bucket("res://data/chars/kfm/kfm.sff")
	# var face_image = bucket.get_images()[9000][1]
	# var node = image_to_sprite(face_image)
	# node.position = Vector2(100, 100)
	# self.add_child(node)
	# air_parser.load_air('res://data/chars/kfm/kfm.air')
	var player1 = Player.new()
	player1.load_data('res://data/chars/kfm/kfm.def')
	player1.position = Vector2(300, 300)
	self.add_child(player1)
