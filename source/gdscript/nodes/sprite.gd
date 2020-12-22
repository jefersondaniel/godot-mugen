extends AnimatedSprite

var animation_player: AnimationPlayer = null
var attacking_area_2d: Area2D = null
var collision_area_2d: Area2D = null
var images: Dictionary = {}
var animations: Dictionary = {}
var looptimes: Dictionary = {}
var element_by_tick: Dictionary = {} # Map at which tick each element starts
var boxes = {1: [], 2: []}
var current_animation: int = 0
var animation_time: int = 0
var animation_element: int = 0
var animation_looptime: int = 0
var tick_length: float = 1

func _init(_images, _animations):
    var empty_image = Image.new()
    var sprite_frames = SpriteFrames.new()
    var empty_texture = null
    var frame_index = 1
    var frame_mapping = {}
    var image_mapping = {}

    animations = _animations
    images = _images
    animation_player = AnimationPlayer.new()
    animation_player.playback_active = false

    # Prepare an empty texture
    empty_image.create_from_data(1, 1, false, Image.FORMAT_RGBA8, PoolByteArray([0,0,0,0]))
    empty_texture = ImageTexture.new()
    empty_texture.create_from_image(empty_image, 0)

    # Load animation spec
    sprite_frames.add_frame('default', empty_texture)

    for image_key in images:
        var image = images[image_key]
        frame_mapping[image_key] = frame_index
        image_mapping[image_key] = {
            'offset': Vector2(-image['x'], -image['y']),
            'size': image['image'].get_size(),
        }
        frame_index = frame_index + 1
        sprite_frames.add_frame('default', image_to_texture(image['image']))

    for animation_key in animations:
        create_animation(animation_key, frame_mapping, image_mapping, true)
        create_animation(animation_key, frame_mapping, image_mapping, false)

    self.set_sprite_frames(sprite_frames)
    self.set_animation('default')
    self.centered = false
    self.name = 'AnimatedSprite'
    self.show_behind_parent = true

func create_animation(animation_key, frame_mapping, image_mapping, is_facing_right):
    var animation_size = animations[animation_key]['sets'].size()
    var current_animation_frame = 0
    var current_looptime = 0
    var collisions = {} # Map {frame: {type: [boxes]}}, will be merged by animation player
    var last_defaults = {1: [], 2: []}
    var current_element_by_tick = {}
    var animation_name_suffix = 'left'
    var loop = false

    if is_facing_right:
        animation_name_suffix = 'right'

    for collision in animations[animation_key]['collisions']:
        if not collisions.get(collision['frame']):
            collisions[collision['frame']] = {}
        collisions[collision['frame']][collision['type']] = inverse_boxes(collision['boxes'], is_facing_right)
        if collision['default']:
            last_defaults[collision['type']] = inverse_boxes(collision['boxes'], is_facing_right)
        else:
            collisions[collision['frame'] + 1] = {}
            collisions[collision['frame'] + 1][collision['type']] = last_defaults[collision['type']]

    for set_key in range(0, animation_size):
        var animation_name = '%s-%s' % [animation_key, set_key]
        var animation_frames = animations[animation_key]['sets'][set_key]['frames']
        if null == animation_frames.back():
            printerr("Invalid animation key")
        var image = null
        var image_offset = null
        var frame_offset = null
        if set_key == 0 and animation_size > 1:
            loop = false
        var animation = Animation.new()
        var frame_track = animation.add_track(Animation.TYPE_VALUE)
        var offset_track = animation.add_track(Animation.TYPE_VALUE)
        var element_number_track = animation.add_track(Animation.TYPE_VALUE)
        var collision_track = animation.add_track(Animation.TYPE_METHOD)
        loop = false if animation_frames.back()['ticks'] == -1 else true

        animation.set_loop(loop)
        animation.track_set_path(frame_track, ':frame')
        animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
        animation.track_set_path(offset_track, ':offset')
        animation.value_track_set_update_mode(offset_track, Animation.UPDATE_DISCRETE)
        animation.track_set_path(element_number_track, ':animation_element')
        animation.value_track_set_update_mode(element_number_track, Animation.UPDATE_DISCRETE)
        animation.track_set_path(collision_track, '.')

        var frame_value = 0
        var frame_width = 0
        var current_set_time = 0.0
        var frame_key: String

        for frame in animation_frames:
            frame_key = '%s-%s' % [frame['groupno'], frame['imageno']]
            if frame['groupno'] >= 0 && frame_mapping.has(frame_key):
                frame_value = frame_mapping[frame_key]
                frame_width = image_mapping[frame_key]['size'].x
                image_offset = image_mapping[frame_key]['offset']
            else:
                frame_value = 0
                image_offset = Vector2(0, 0)
            if frame['groupno'] >= 0 and not frame_mapping.has(frame_key):
                printerr("Image not found: %s,%s" % [frame['groupno'], frame['imageno']])
            frame_offset = Vector2(
                image_offset.x - frame['offset'][0],
                image_offset.y - frame['offset'][1]
            )
            if not is_facing_right:
                frame_offset.x = -frame_width - frame_offset.x
            animation.track_insert_key(offset_track, current_set_time, frame_offset)
            animation.track_insert_key(frame_track, current_set_time, frame_value)
            animation.track_insert_key(element_number_track, current_set_time, current_animation_frame + 1)
            if collisions.get(current_animation_frame):
                var method = {
                    'method': 'set_collision_boxes',
                    'args': [collisions[current_animation_frame]]
                }
                animation.track_insert_key(collision_track, current_set_time, method)

            current_element_by_tick[current_animation_frame] = current_looptime
            current_looptime += max(1, frame['ticks'])
            current_set_time += (max(1, frame['ticks']) * tick_length)
            current_animation_frame += 1

        animation.set_length(current_set_time)
        animation_player.add_animation("%s-%s" % [animation_name, animation_name_suffix], animation)

    if loop:
        looptimes[animation_key] = current_looptime
    else:
        looptimes[animation_key] = -1

    element_by_tick[animation_key] = current_element_by_tick

func change_anim(value: int):
    # TODO: Support element
    animation_time = 0
    animation_element = 0
    current_animation = value
    animation_looptime = looptimes[value]
    var animation_name_suffix = 'left'

    if not flip_h:
        animation_name_suffix = 'right'

    var key = '%s-0-%s' % [value, animation_name_suffix]
    animation_player.stop(true)
    animation_player.play(key)
    if animations[value]['sets'].size() > 1:
        animation_player.queue('%s-1-%s' % [value, animation_name_suffix])

func has_anim(value: int):
    return animations.has(value)

func set_collision_boxes(_boxes):
    boxes = {}
    for type in _boxes:
        boxes[type] = _boxes[type]
    update_collision_boxes()
    update()

func update_collision_boxes():
    if self.attacking_area_2d:
        self.attacking_area_2d.queue_free()

    if self.collision_area_2d:
        self.collision_area_2d.queue_free()

    self.attacking_area_2d = Area2D.new()
    self.attacking_area_2d.set_collision_layer(1)
    self.attacking_area_2d.set_collision_mask_bit(1, true)
    self.attacking_area_2d.set_collision_mask_bit(2, true)

    self.collision_area_2d = Area2D.new()
    self.collision_area_2d.set_collision_layer(2)
    self.collision_area_2d.set_collision_mask_bit(1, true)
    self.collision_area_2d.set_collision_mask_bit(2, true)

    for type in boxes:
        for points in boxes[type]:
            self.create_collision_box(type, points)

    self.add_child(self.attacking_area_2d)
    self.add_child(self.collision_area_2d)

func check_collision(other, type: int) -> bool:
    if not other.collision_area_2d or not self.collision_area_2d or not other.attacking_area_2d or not self.attacking_area_2d:
        return false

    if type == 1:
        return self.attacking_area_2d.overlaps_area(other.collision_area_2d) or self.attacking_area_2d.overlaps_area(other.attacking_area_2d)

    if type == 2:
        return self.collision_area_2d.overlaps_area(other.collision_area_2d) or self.collision_area_2d.overlaps_area(other.attacking_area_2d)

    return false

func check_attack_collision(other) -> bool:
    if not other.collision_area_2d or not self.attacking_area_2d:
        return false

    return self.attacking_area_2d.overlaps_area(other.collision_area_2d)

func create_collision_box(type: int, points: Array):
    var rectangle_shape: RectangleShape2D = RectangleShape2D.new()
    rectangle_shape.extents = Vector2(abs(points[2] - points[0]) / 2, abs(points[3] - points[1]) / 2)

    var collision_shape: CollisionShape2D = CollisionShape2D.new()
    collision_shape.position = Vector2(
        points[0] + (points[2] - points[0]) / 2,
        points[1] + (points[3] - points[1]) / 2
    )
    collision_shape.set_shape(rectangle_shape)

    if type == 1:
        self.attacking_area_2d.add_child(collision_shape)
    else:
        self.collision_area_2d.add_child(collision_shape)

func image_to_texture(image):
    var texture = ImageTexture.new()
    texture.create_from_image(image, 0)
    return texture

func get_element_time(element):
    var current_element_by_tick = element_by_tick[int(current_animation)]
    return current_element_by_tick[element - 1]

func get_time_from_the_end():
    if animation_looptime == -1:
        return animation_time + 1

    return animation_time - animation_looptime

func inverse_boxes(boxes, is_facing_right):
    if is_facing_right:
        return boxes

    var result: Array = []

    for box in boxes:
        result.push_back([
            -box[0],
            box[1],
            -box[2],
            box[3],
        ])

    return result

func handle_tick():
    animation_player.advance(tick_length)
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
