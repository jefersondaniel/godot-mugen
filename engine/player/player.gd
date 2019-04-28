extends KinematicBody2D

var configuration_parser = load('res://engine/configuration_parser.gd').new()
var sprite_manager = load('res://engine/sprite_manager.gd').new()
var air_parser = load('res://engine/air_parser.gd').new()

var animations = null
var animated_sprite = null
var animation_player = null
var empty_texture = null
var boxes = {1: [], 2: []}

func image_to_texture(image):
	var texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	return texture

func load_data(path):
	var definition = configuration_parser.load_configuration(path)
	var folder = path.substr(0, path.find_last('/'))
	var sprite_path = '%s/%s' % [folder, definition['files']['sprite']]
	var animation_path = '%s/%s' % [folder, definition['files']['anim']]
	var images = sprite_manager.make_sprite_bucket(sprite_path).get_images()
	var empty_image = Image.new()
	var sprite_frames = SpriteFrames.new()
	var frame_index = 1
	var frame_mapping = {}
	var offset_mapping = {}

	# Prepare an empty texture
	empty_image.create_from_data(1, 1, false, Image.FORMAT_RGBA8, PoolByteArray([0,0,0,0]))
	empty_texture = ImageTexture.new()
	empty_texture.create_from_image(empty_image, 0)

	# Load animation spec
	animations = air_parser.load_air(animation_path)
	animated_sprite = AnimatedSprite.new()
	animation_player = AnimationPlayer.new()

	# Setup AnimatedSprite
	sprite_frames.add_animation('default')
	sprite_frames.add_frame('default', empty_texture)

	for group_key in images:
		for image_key in images[group_key]:
			var image = images[group_key][image_key]
			frame_mapping['%s;%s' % [group_key, image_key]] = frame_index
			offset_mapping['%s;%s' % [group_key, image_key]] = Vector2(-image['x'], -image['y'])
			frame_index = frame_index + 1
			sprite_frames.add_frame('default', image_to_texture(image['image']))

	for animation_key in animations:
		var animation_size = animations[animation_key]['sets'].size()
		var current_animation_frame = 0
		var collisions = {} # Map {frame: {type: [boxes]}}, will be merged by animation player
		var last_defaults = {1: [], 2: []}

		for collision in animations[animation_key]['collisions']:
			if not collisions.get(collision['frame']):
				collisions[collision['frame']] = {}
			collisions[collision['frame']][collision['type']] = collision['boxes']
			if collision['default']:
				last_defaults[collision['type']] = collision['boxes']
			else:
				collisions[collision['frame'] + 1] = {}
				collisions[collision['frame'] + 1][collision['type']] = last_defaults[collision['type']]

		for set_key in range(0, animation_size):
			var animation_name = '%s;%s' % [animation_key, set_key]
			var animation_frames = animations[animation_key]['sets'][set_key]['frames']
			var loop = false if animation_frames.back()['ticks'] == -1 else true
			var image = null
			var image_offset = null
			var frame_offset = null
			if set_key == 0 and animation_size > 1:
				loop = false
			var animation = Animation.new()
			var frame_track = animation.add_track(Animation.TYPE_VALUE)
			var offset_track = animation.add_track(Animation.TYPE_VALUE)
			var collision_track = animation.add_track(Animation.TYPE_METHOD)

			animation.set_loop(loop)
			animation.track_set_path(frame_track, 'AnimatedSprite:frame')
			animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
			animation.track_set_path(offset_track, 'AnimatedSprite:offset')
			animation.value_track_set_update_mode(offset_track, Animation.UPDATE_DISCRETE)

			var frame_value = 0
			var current_set_time = 0.0
			var tick_length = 1.0 / 60.0

			for frame in animation_frames:
				if frame['groupno'] >= 0:
					frame_value = frame_mapping['%s;%s' % [frame['groupno'], frame['imageno']]]
					image_offset = offset_mapping['%s;%s' % [frame['groupno'], frame['imageno']]]
				else:
					frame_value = 0
					image_offset = Vector2(0, 0)
				frame_offset = Vector2(
					image_offset.x + frame['offset'][0],
					image_offset.y + frame['offset'][1]
				)
				animation.track_insert_key(offset_track, current_set_time, frame_offset)
				animation.track_insert_key(frame_track, current_set_time, frame_value)
				if collisions.get(current_animation_frame):
					var method = {
						'method': 'change_boxes',
						'args': [collisions[current_animation_frame]]
					}
					animation.track_insert_key(collision_track, current_set_time, method)
				current_set_time += (frame['ticks'] * tick_length)
				current_animation_frame += 1

			animation.set_length(current_set_time)
			animation_player.add_animation(animation_name, animation)

	animated_sprite.set_sprite_frames(sprite_frames)
	animated_sprite.set_animation('default')
	animated_sprite.centered = false
	animated_sprite.scale = Vector2(1, 1)
	animated_sprite.name = 'AnimatedSprite'
	animated_sprite.show_behind_parent = true
	change_anim(41)

func _ready():
	self.add_child(animation_player)
	self.add_child(animated_sprite)

func change_anim(value):
	var key = '%s;0' % [value]
	animation_player.play(key)
	if animations[value]['sets'].size() > 1:
		animation_player.queue('%s;1' % [value])

func change_boxes(_boxes):
	for type in _boxes:
		boxes[type] = _boxes[type]
	update()

func _draw():
	for type in boxes:
		var points = boxes[type]
		var color = Color.red if type == 1 else Color.blue
		for point in points:
			draw_line(Vector2(point[0], point[1]), Vector2(point[2], point[1]), color)
			draw_line(Vector2(point[0], point[3]), Vector2(point[2], point[3]), color)
			draw_line(Vector2(point[0], point[1]), Vector2(point[0], point[3]), color)
			draw_line(Vector2(point[2], point[1]), Vector2(point[2], point[3]), color)
