extends Node

var sprite_manager = load('res://engine/sprite_manager.gd').new()
var air_parser = load('./engine/air_parser.gd').new()

func image_to_sprite(image):
	var texture = ImageTexture.new()
	texture.create_from_image(image, 0)

	var sprite = Sprite.new()
	sprite.set_texture(texture)

	return sprite

func _init():
	# var bucket = sprite_manager.make_sprite_bucket("res://data/chars/kfm/kfm.sff")
	# var face_image = bucket.get_images()[9000][1]
	# var node = image_to_sprite(face_image)
	# node.position = Vector2(100, 100)
	# self.add_child(node)
	air_parser.load_air('res://data/chars/kfm/kfm.air')
