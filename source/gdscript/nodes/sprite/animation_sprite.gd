extends AnimatedSprite

var AnimationManager = load("res://source/gdscript/nodes/sprite/animation_manager.gd")

var sprite_bundle: Object
var animation_manager = null
var attacking_area_2d: Area2D = null
var collision_area_2d: Area2D = null
var boxes = {1: [], 2: []}
var boxes_facing_right: bool = true
var frame_mapping = {}
var image_mapping = {}
var is_facing_right: bool = true
var flip_v_override: bool = false
var flip_h_override: bool = false
var debug_collisions: bool = false

func _init(sprite_bundle, animations):
    self.sprite_bundle = sprite_bundle

    animation_manager = AnimationManager.new(animations)
    animation_manager.connect("element_update", self, "handle_element_update")

    load_sprite_frames(animations)
    set_animation("default")

    centered = false
    name = "AnimatedSprite"
    # show_behind_parent = true TODO: Refactor collision

func load_sprite_frames(animations):
    var sprite_frames = SpriteFrames.new()
    var frame_index = 1
    var images: Dictionary = {}

    for animation_key in animations:
        for element in animations[animation_key].elements:
            var image_key = "%s-%s" % [element.groupno, element.imageno]
            if images.has(image_key):
                continue
            var image = sprite_bundle.get_image([element.groupno, element.imageno])
            if image:
                images[image_key] = image

    sprite_frames.add_frame("default", sprite_bundle.create_empty_texture())

    for image_key in images:
        var image = images[image_key]
        frame_mapping[image_key] = frame_index
        image_mapping[image_key] = {
            "offset": Vector2(-image["x"], -image["y"]),
            "size": image["image"].get_size(),
        }
        frame_index = frame_index + 1
        sprite_frames.add_frame("default", sprite_bundle.create_texture(image))

    set_sprite_frames(sprite_frames)

func set_image(groupno, imageno, offset):
    var frame_key = '%s-%s' % [groupno, imageno]
    var frame_value = 0
    var frame_width = 0
    var image_offset = Vector2(0, 0)

    if groupno >= 0 && frame_mapping.has(frame_key):
        frame_value = frame_mapping[frame_key]
        frame_width = image_mapping[frame_key]['size'].x
        image_offset = image_mapping[frame_key]['offset']

    if groupno >= 0 and not frame_mapping.has(frame_key):
        printerr("Image not found: %s,%s" % [groupno, imageno])

    var frame_offset = Vector2(
        image_offset.x + offset.x,
        image_offset.y + offset.y
    )
    if not is_facing_right:
        frame_offset.x = -frame_width - frame_offset.x

    self.frame = frame_value
    self.offset = frame_offset

    update_image_flip()

func change_anim(value: int, element_index: int = 0):
    animation_manager.set_local_animation(value, element_index)

func change_foreign_anim(foreign_animation_manager, value: int, element_index: int = 0):
    animation_manager.set_foreign_animation(foreign_animation_manager, value, element_index)

func set_collisions(collisions):
    boxes = {}
    if collisions[1]:
        boxes[1] = collisions[1].boxes
    if collisions[2]:
        boxes[2] = collisions[2].boxes
    boxes_facing_right = true # By default boxes are directed to right
    fix_boxes_direction()
    update_collision_boxes()
    update()

func set_facing_right(value: bool):
    if is_facing_right == value:
        return
    is_facing_right = value
    update_image_flip()
    fix_boxes_direction()

func update_image_flip():
    set_flip_h(!is_facing_right != flip_h_override)
    set_flip_v(flip_v_override)

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
        return self.overlaps_area(attacking_area_2d, other.collision_area_2d) or self.overlaps_area(attacking_area_2d, other.attacking_area_2d)

    if type == 2:
        return self.overlaps_area(collision_area_2d, other.collision_area_2d) or self.overlaps_area(collision_area_2d, other.attacking_area_2d)

    return false

func check_attack_collision(other) -> bool:
    if not other.collision_area_2d or not self.attacking_area_2d:
        return false

    return self.overlaps_area(attacking_area_2d, other.collision_area_2d)

func overlaps_area(area1, area2) -> bool:
    var space_state = get_world_2d().direct_space_state

    for shape in area1.get_children():
        var query = Physics2DShapeQueryParameters.new()
        query.set_shape(shape.shape)
        query.set_exclude([self.collision_area_2d, self.attacking_area_2d])
        query.set_collide_with_areas(true)
        query.set_transform(shape.get_global_transform())
        var results = space_state.intersect_shape(query, 64)
        for result in results:
           if result['collider'] == area2:
              return true

    return false

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

func fix_boxes_direction():
    if boxes_facing_right == is_facing_right or is_facing_right:
        return
    var left_boxes = {1: [], 2: []}
    for type in boxes:
        for box in boxes[type]:
            left_boxes[type].push_back([
                -box[0],
                box[1],
                -box[2],
                box[3],
            ])
    boxes = left_boxes
    is_facing_right = false

func get_animation_element_time(element_number):
    var animation = self.animation_manager.animation
    if element_number == null:
        return 0
    var element_index = element_number - 1
    if animation.total_elements < element_index:
        return 0
    var animation_time = self.animation_manager.animation_time
    var element_start_time = animation.get_element_start_time(element_index)
    return animation_time - element_start_time

func get_time_from_the_end():
    var animation = self.animation_manager.animation
    var animation_time = self.animation_manager.animation_time
    if animation.total_time == -1:
        return animation_time + 1
    return animation_time - animation.total_time

func get_current_animation():
    return animation_manager.animation.identifier

func get_animation_element():
    return animation_manager.element.id

func handle_element_update(element, collisions):
    var flip_flags = element.flags[0] if len(element.flags) > 0 else null
    flip_h_override = false
    flip_v_override = false

    if flip_flags:
        if 'h' in flip_flags:
            flip_h_override = true
        if 'v' in flip_flags:
            flip_v_override = true

    set_image(element.groupno, element.imageno, element.offset)
    set_collisions(collisions)

func _draw():
    if debug_collisions:
        draw_collision_boxes()

func draw_collision_boxes():
    for type in boxes:
        var points = boxes[type]
        var color = Color.red if type == 1 else Color.blue
        for point in points:
            draw_line(Vector2(point[0], point[1]), Vector2(point[2], point[1]), color)
            draw_line(Vector2(point[0], point[3]), Vector2(point[2], point[3]), color)
            draw_line(Vector2(point[0], point[1]), Vector2(point[0], point[3]), color)
            draw_line(Vector2(point[2], point[1]), Vector2(point[2], point[3]), color)

func _process(delta: float):
    handle_tick()

func handle_tick():
    animation_manager.handle_tick()
