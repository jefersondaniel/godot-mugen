extends AnimatedSprite

var animation_player: AnimationPlayer = null
var images: Dictionary = {}
var animations: Dictionary = {}
var looptimes: Dictionary = {}
var element_by_tick: Dictionary = {} # Map at which tick each element starts
var boxes = {1: [], 2: []}
var current_animation: int = 0
var animation_time: int = 0
var animation_element: int = 0
var animation_element_time: int = 0
var animation_looptime: int = 0

func _init(_images, _animations):
    var empty_image = Image.new()
    var sprite_frames = SpriteFrames.new()
    var empty_texture = null
    var frame_index = 1
    var frame_mapping = {}
    var offset_mapping = {}

    animations = _animations
    images = _images
    animation_player = AnimationPlayer.new()

    # Prepare an empty texture
    empty_image.create_from_data(1, 1, false, Image.FORMAT_RGBA8, PoolByteArray([0,0,0,0]))
    empty_texture = ImageTexture.new()
    empty_texture.create_from_image(empty_image, 0)

    # Load animation spec
    animation_player = AnimationPlayer.new()
    sprite_frames.add_frame('default', empty_texture)

    for image_key in images:
        var image = images[image_key]
        frame_mapping[image_key] = frame_index
        offset_mapping[image_key] = Vector2(-image['x'], -image['y'])
        frame_index = frame_index + 1
        sprite_frames.add_frame('default', image_to_texture(image['image']))

    for image_key in images:
        var image = images[image_key]
        frame_mapping[image_key] = frame_index
        offset_mapping[image_key] = Vector2(-image['x'], -image['y'])
        frame_index = frame_index + 1
        sprite_frames.add_frame('default', image_to_texture(image['image']))

    for animation_key in animations:
        var animation_size = animations[animation_key]['sets'].size()
        var current_animation_frame = 0
        var current_looptime = 0
        var collisions = {} # Map {frame: {type: [boxes]}}, will be merged by animation player
        var last_defaults = {1: [], 2: []}
        var current_element_by_tick = {}

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
            var animation_name = '%s-%s' % [animation_key, set_key]
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
            animation.track_set_path(frame_track, ':frame')
            animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
            animation.track_set_path(offset_track, ':offset')
            animation.value_track_set_update_mode(offset_track, Animation.UPDATE_DISCRETE)

            var frame_value = 0
            var current_set_time = 0.0
            var tick_length = 1.0 / 60.0

            for frame in animation_frames:
                if frame['groupno'] >= 0:
                    frame_value = frame_mapping['%s-%s' % [frame['groupno'], frame['imageno']]]
                    image_offset = offset_mapping['%s-%s' % [frame['groupno'], frame['imageno']]]
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

                current_element_by_tick[current_animation_frame] = current_looptime
                current_looptime += max(1, frame['ticks'])
                current_set_time += (max(1, frame['ticks']) * tick_length)
                current_animation_frame += 1

            animation.set_length(current_set_time)
            animation_player.add_animation(animation_name, animation)

        looptimes[animation_key] = current_looptime
        element_by_tick[animation_key] = current_element_by_tick

    self.set_sprite_frames(sprite_frames)
    self.set_animation('default')
    self.centered = false
    self.scale = Vector2(1, 1)
    self.name = 'AnimatedSprite'
    self.show_behind_parent = true

func change_anim(value: int):
    animation_time = 0
    animation_element = 0
    animation_element_time = 0
    current_animation = value
    animation_looptime = looptimes[value]

    var key = '%s-0' % [value]
    animation_player.play(key)
    if animations[value]['sets'].size() > 1:
        animation_player.queue('%s-1' % [value])

func has_anim(value: int):
    return animations.has(value)

func change_boxes(_boxes):
    for type in _boxes:
        boxes[type] = _boxes[type]
    update()

func image_to_texture(image):
    var texture = ImageTexture.new()
    texture.create_from_image(image, 0)
    return texture

func get_element_time(element):
    var current_element_by_tick = element_by_tick[int(current_animation)]
    return current_element_by_tick[element]

func _process(delta):
    animation_time = animation_time + 1

func _draw():
    for type in boxes:
        var points = boxes[type]
        var color = Color.red if type == 1 else Color.blue
        for point in points:
            draw_line(Vector2(point[0], point[1]), Vector2(point[2], point[1]), color)
            draw_line(Vector2(point[0], point[3]), Vector2(point[2], point[3]), color)
            draw_line(Vector2(point[0], point[1]), Vector2(point[0], point[3]), color)
            draw_line(Vector2(point[2], point[1]), Vector2(point[2], point[3]), color)

func _ready():
    add_child(animation_player)
    change_anim(0)
