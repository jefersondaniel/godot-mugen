extends Node

var sff_parser = load('res://engine/sff_parser.gd').new()

class SpriteBucket:
	var sff
	var path
	var sff_parser

	func _init(sff, path, sff_parser):
		self.sff = sff
		self.path = path
		self.sff_parser = sff_parser
	
	func get_image_count():
		return self.sff['total_frames']

	func get_palette_count():
		return self.sff['total_palettes']

	func get_images(filters = null):
		var file = File.new()
		file.open(self.path, file.READ)
		var images = self.sff_parser.get_images(file, self.sff, filters)
		file.close()
		return images

func make_sprite_bucket(path):
	var file = File.new()
	file.open(path, file.READ)
	var sff = sff_parser.load_sff(file)
	if not sff:
		return null
	return SpriteBucket.new(sff, path, sff_parser)
