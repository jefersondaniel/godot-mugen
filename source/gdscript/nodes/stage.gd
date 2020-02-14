extends ParallaxBackground

var gravity = Vector2(0, 0.50)
var ground_y = 400
var backgrounds: Array = []
var camera: Camera2D
var camera_handle: Node2D

var info_name: String = ''
var info_displayname: String = ''
var info_mugenversion: String = ''
var info_author: String = ''
var camera_startx: int = 0
var camera_starty: int = 0
var camera_boundleft: int = 0
var camera_boundright: int = 0
var camera_boundhigh: int = 0
var camera_boundlow: int = 0
var camera_verticalfollow: int = 0
var camera_floortension: int = 0
var camera_tension: int = 0
var player_p1startx: int = 0
var player_p1starty: int = 0
var player_p2startx: int = 0
var player_p2starty: int = 0
var player_p1facing: int = 0
var player_p2facing: int = 0
var player_leftbound: int = 0
var player_rightbound: int = 0
var bound_screenleft: int = 0
var bound_screenright: int = 0
var stageinfo_zoffset: int = 0
var stageinfo_zoffsetlink: int = 0
var stageinfo_autoturn: int = 1
var stageinfo_resetbg: int = 0
var stageinfo_localcoord: Vector2 = Vector2(320, 240)
var stageinfo_xscale: int = 0
var stageinfo_yscale: int = 0
var shadow_intensity: int = 0
var shadow_color: Array = []
var shadow_yscale: int = 0
var shadow_fade_range: Array = []
var reflection_reflect: int = 0
var music_bgmusic: String = ''
var music_bgvolume: int = 0

func setup():
    setup_camera()

    for background in backgrounds:
        background.setup(self)
        add_child(background)

func setup_camera():
    var scale: Vector2 = constants.get_scale(stageinfo_localcoord)

    camera_handle = Node2D.new()

    set_camera_position(Vector2(camera_startx, camera_starty) * scale)

    camera = Camera2D.new()
    # camera.offset = constants.WINDOW_SIZE / 2 * Vector2(0, 1)
    # camera.limit_left = camera_boundleft * scale.x
    # camera.limit_right = camera_boundright * scale.x
    camera.limit_top = get_bound_top()
    camera.limit_bottom = get_bound_bottom()

    print({
        'get_bound_left': get_bound_left(),
        'get_bound_right': get_bound_right(),
        'get_bound_top': get_bound_top(),
        'get_bound_bottom': get_bound_bottom()
    })

    camera_handle.add_child(camera)
    add_child(camera_handle)
    camera.make_current()

func get_bound_left():
    var scale: Vector2 = constants.get_scale(stageinfo_localcoord)

    return -(constants.WINDOW_SIZE.x / 2) + (camera_boundleft * scale.x)

func get_bound_right():
    var scale: Vector2 = constants.get_scale(stageinfo_localcoord)

    return (constants.WINDOW_SIZE.x / 2) + (camera_boundright * scale.x)

func get_bound_top():
    var scale: Vector2 = constants.get_scale(stageinfo_localcoord)

    return camera_boundhigh * scale.y

func get_bound_bottom():
    var scale: Vector2 = constants.get_scale(stageinfo_localcoord)

    return constants.WINDOW_SIZE.y + (camera_boundlow * scale.x)

func set_camera_position(position: Vector2):
    camera_handle.position = Vector2(
        position.x,
        position.y + constants.WINDOW_SIZE.y / 2
    )

var direction: float = 1.0

func _process(delta: float):
    var width: float = 150.0
    var velocity: float = 150.0

    if camera_handle.position.x > width:
        direction = -1
    elif camera_handle.position.x < -width:
        direction = 1

    camera_handle.position.x += direction * velocity * delta