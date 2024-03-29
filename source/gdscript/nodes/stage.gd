extends Node2D

var root_background: ParallaxBackground
var definition = null

# Child Nodes
var gravity = Vector2(0, 0.475)
var backgrounds: Array = []
var camera: Camera2D
var camera_handle: Node2D
var camera_offset: Vector2
var player_layer: ParallaxLayer
var players: Array = []

# EnvShake
var envshake_timeticks: float = 0.0
var envshake_time: float = 0.0
var envshake_frequency: float = 0.0
var envshake_amplitude: float = 0.0
var envshake_phase: float = 0.0
var envshake_offset: Vector2 = Vector2(0, 0)

func setup():
    root_background = ParallaxBackground.new()
    add_child(root_background)

    setup_camera()

    for background in backgrounds:
        background.setup(self)
        root_background.add_child(background)

    player_layer = ParallaxLayer.new()
    player_layer.motion_scale = Vector2(1, 1)
    root_background.add_child(player_layer)

func setup_camera():
    var scale: Vector2 = constants.get_scale(definition.stageinfo_localcoord)

    camera_handle = Node2D.new()
    camera_offset = Vector2(0, constants.WINDOW_SIZE.y / 2)

    reset_camera_position()

    camera = Camera2D.new()
    # camera.offset = constants.WINDOW_SIZE / 2 * Vector2(0, 1)
    camera_handle.add_child(camera)
    root_background.add_child(camera_handle)
    camera.make_current()

func reset_camera_position():
    set_camera_position(Vector2(definition.camera_startx, definition.camera_starty) * scale)

func reset():
    reset_camera_position()

func get_bound_left():
    var scale: Vector2 = constants.get_scale(definition.stageinfo_localcoord)

    return -(constants.WINDOW_SIZE.x / 2) + (definition.camera_boundleft * scale.x)

func get_bound_right():
    var scale: Vector2 = constants.get_scale(definition.stageinfo_localcoord)

    return (constants.WINDOW_SIZE.x / 2) + (definition.camera_boundright * scale.x)

func get_bound_top():
    var scale: Vector2 = constants.get_scale(definition.stageinfo_localcoord)

    return definition.camera_boundhigh * scale.y

func get_bound_bottom():
    var scale: Vector2 = constants.get_scale(definition.stageinfo_localcoord)

    return constants.WINDOW_SIZE.y + (definition.camera_boundlow * scale.x)

func set_camera_position(position: Vector2):
    camera_handle.position = position + camera_offset

    for background in backgrounds:
        background.handle_camera_update(self)

func get_camera_relative_position() -> Vector2:
    return camera.get_camera_position() - camera_offset

func get_movement_area() -> Rect2:
    # Area that restrict player movement

    return Rect2(
        get_camera_relative_position() - constants.WINDOW_SIZE / 2,
        constants.WINDOW_SIZE
    )

func get_position_offset():
    var scale: Vector2 = constants.get_scale(definition.stageinfo_localcoord)

    return Vector2(
        0,
        definition.stageinfo_zoffset * scale.y
    )

func get_starting_pos(team: int) -> Vector2:
    var pos: Vector2
    var offset: Vector2 = get_position_offset()
    var scale: Vector2 = constants.get_scale(definition.stageinfo_localcoord)

    if team == 1:
        pos = Vector2(scale.x * definition.player_p1startx + offset.x, scale.y * definition.player_p1starty + offset.y)
    else:
        pos = Vector2(scale.y * definition.player_p2startx + offset.x, scale.y * definition.player_p2starty + offset.y)

    return pos

func get_stage_scale() -> Vector2:
    return constants.get_scale(definition.stageinfo_localcoord)

func add_player(player):
    players.append(player)
    player_layer.add_child(player)

func update_tick():
    update_envshake()
    update_camera()

func update_camera():
    var scale: Vector2 = get_stage_scale()
    var movement: Vector2 = Vector2(0, 0)
    var min_pos: Vector2 = Vector2(100000, 100000)
    var max_pos: Vector2 = Vector2(-100000, -100000)
    var camera_relative_position: Vector2 = get_camera_relative_position()
    var camera_left: float = camera_relative_position.x - constants.WINDOW_SIZE.x / 2
    var camera_right: float = camera_relative_position.x + constants.WINDOW_SIZE.x / 2
    var drag_margin_left: float = camera_left + definition.camera_tension * scale.x
    var drag_margin_right: float = camera_right - definition.camera_tension * scale.x

    for player in players:
        var player_left: float = player.get_left_position()
        var player_right: float = player.get_right_position()

        # TODO: handle vertical camera

        if player_left < min_pos.x:
            min_pos.x = player_left
        if player_right > max_pos.x:
            max_pos.x = player_right

    var must_scroll_left = min_pos.x <= drag_margin_left
    var must_scroll_right = max_pos.x >= drag_margin_right
    var left_margin_distance = -abs(min_pos.x - drag_margin_left)
    var right_margin_distance = abs(max_pos.x - drag_margin_right)

    if must_scroll_left:
        movement.x = left_margin_distance
    if must_scroll_right:
        movement.x = right_margin_distance
    if must_scroll_left and must_scroll_right:
        movement.x = (left_margin_distance + right_margin_distance) / 2

    camera_handle.position += movement

    if camera_handle.position.x - constants.WINDOW_SIZE.x / 2 < get_bound_left():
        camera_handle.position.x = get_bound_left() + constants.WINDOW_SIZE.x / 2
    if camera_handle.position.x + constants.WINDOW_SIZE.x / 2 > get_bound_right():
        camera_handle.position.x = get_bound_right() - constants.WINDOW_SIZE.x / 2

    camera.offset = envshake_offset

func update_envshake():
    var scale: Vector2 = get_stage_scale()

    if envshake_time > 0 and envshake_timeticks < envshake_time:
        envshake_timeticks += 1
        var movement: float = envshake_amplitude * scale.y * sin(envshake_timeticks * envshake_frequency + envshake_phase);
        envshake_offset = Vector2(0, movement)
    else:
        envshake_offset = Vector2(0, 0)

func setup_envshake(time: float, frequency: float, amplitude: float, phase: float):
    envshake_timeticks = 0
    envshake_time = time
    envshake_frequency = frequency
    envshake_amplitude = amplitude
    envshake_phase = phase
