extends KinematicBody2D

var configuration_parser = load('res://engine/configuration_parser.gd').new()
var sprite_manager = load('res://engine/sprite_manager.gd').new()
var air_parser = load('./engine/air_parser.gd').new()

var animations = null
var animated_sprite = null
var offsets = {}
var animation_queue = []

func image_to_texture(image):
	var texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	return texture

func load_data(path):
	var definition = configuration_parser.load_configuration(path)
	var separator_idx = path.find_last('/')
	var folder = path.substr(0, separator_idx)
	var sprite_path = '%s/%s' % [folder, definition['files']['sprite']]
	var animation_path = '%s/%s' % [folder, definition['files']['anim']]
	var images = sprite_manager.make_sprite_bucket(sprite_path).get_images()

	animations = air_parser.load_air(animation_path)
	animated_sprite = AnimatedSprite.new()

	var sprite_frames = SpriteFrames.new()
	var empty_texture = ImageTexture.new()
	var texture = null
	var empty_image = Image.new()
	empty_image.create_from_data(1, 1, false, Image.FORMAT_RGBA8, PoolByteArray([0,0,0,0]))
	empty_texture.create_from_image(empty_image, 0)

	for animation_key in animations:
		var animation_size = animations[animation_key]['sets'].size()
		for set_key in range(0, animation_size):
			var animation_name = '%s;%s' % [animation_key, set_key]
			var animation_frames = animations[animation_key]['sets'][set_key]['frames']
			var animation_tick = 0
			var loop = false if animation_frames.back()['ticks'] == -1 else true
			var image = null
			var image_offset = null
			var frame_offset = null
			if set_key == 0 and animation_size > 1:
				loop = false
			sprite_frames.add_animation(animation_name)
			sprite_frames.set_animation_speed(animation_name, 60)
			sprite_frames.set_animation_loop(animation_name, loop)
			for frame in animation_frames:
				if frame['groupno'] >= 0:
					image = images[frame['groupno']][frame['imageno']]
					image_offset = Vector2(-image['x'], -image['y'])
					texture = image_to_texture(image['image'])
				else:
					image_offset = Vector2(0, 0)
					texture = empty_texture
				frame_offset = Vector2(
					image_offset.x + frame['offset'][0],
					image_offset.y + frame['offset'][1]
				)
				if not offsets.get(animation_name):
					offsets[animation_name] = {}
				offsets[animation_name][animation_tick] = frame_offset
				for tick in range(0, frame['ticks']):
					sprite_frames.add_frame(animation_name, texture)
				animation_tick += frame['ticks']
	animated_sprite.set_sprite_frames(sprite_frames)
	animated_sprite.centered = false
	animated_sprite.scale = Vector2(2, 2)
	animated_sprite.connect('animation_finished', self, '_on_animation_finished')
	animated_sprite.connect('frame_changed', self, '_on_frame_changed')
	change_anim(0)

func _ready():
	self.add_child(animated_sprite)

func _on_frame_changed():
	var animation_offsets = offsets.get(animated_sprite.animation)
	var offset = animation_offsets.get(animated_sprite.frame) if animation_offsets else null
	if offset:
		animated_sprite.offset = offset

func _on_animation_finished():
	var next_animation = animation_queue.pop_front()

	if next_animation:
		animated_sprite.play(next_animation)
		animated_sprite.offset = offsets[next_animation][0]

func change_anim(value):
	var key = '%s;0' % [value]
	animated_sprite.play(key)
	animated_sprite.offset = offsets[key][0]
	if animations[value]['sets'].size() > 1:
		animation_queue.append('%s;1' % [value])
