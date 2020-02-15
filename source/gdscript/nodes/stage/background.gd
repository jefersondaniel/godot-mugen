extends ParallaxLayer

var images: Dictionary = {}
var animations: Dictionary = {}
var id: int = 0
var type: String = 'normal'
var positionlink: int = 0
var velocity: Vector2 = Vector2(0, 0)
var sin_x: Array = []
var sin_y: Array = []
var spriteno: Array = []
var layerno: int = 0
var start: Vector2 = Vector2(0, 0)
var delta: Vector2 = Vector2(1, 1)
var trans: String = 'none'
var alpha: Vector2 = Vector2(1.0, 1.0)
var mask: int = 0
var tile: Vector2 = Vector2(0, 0)
var tilespacing: Vector2 = Vector2(0, 0)
var window: Array = []
var windowdelta: Vector2 = Vector2(0, 0)
var actionno: int = 0
var width: Array = []
var top_xscale: float = 1
var bottom_xscale: float = 1
var yscalestart: int = 0
var yscaledelta: int = 0
var stage_scale: Vector2 = Vector2(1, 1)

var mesh: MeshInstance2D
var texture: ImageTexture
var st: SurfaceTool

func setup(stage):
    st = SurfaceTool.new()

    stage_scale = constants.get_scale(stage.stageinfo_localcoord)
    motion_scale = delta
    motion_offset = -(stage.camera_handle.position - (delta * stage.camera_handle.position))
    z_index = layerno

    setup_mesh(stage)

func setup_mesh(stage):
    var spritekey = '%s-%s' % [spriteno[0], spriteno[1]]

    if not images.has(spritekey):
        printerr("Invalid spriteno: %s,%s" % spriteno)
        return

    var image = images[spritekey]
    var offset = Vector2(image['x'], image['y'])

    create_mesh(image['image'])
    update_mesh(stage.camera)

    # mesh.centered = false
    mesh.position = (start - offset)

    # Scale
    mesh.position = stage_scale * mesh.position

    if trans == 'addalpha':
        # TODO: Implement alpha.y value
        mesh.modulate = Color(1, 1, 1, alpha.x / 256)

    create_tiles(stage, mesh)
    add_child(mesh)

func create_tiles(stage, base):
    # TODO: Improve performance here if needed with regions
    var requested_tiles_top: int = tile.y
    var requested_tiles_left: int = tile.x
    var requested_tiles_right: int = tile.x
    var requested_tiles_bottom: int = tile.y
    var bound_left = stage.get_bound_left()
    var bound_right = stage.get_bound_right()
    var bound_top = stage.get_bound_top()
    var bound_bottom = stage.get_bound_bottom()


    if tile.x == 1:
        requested_tiles_left = ceil(abs(base.position.x - bound_left) / (base.texture.size.x * stage_scale.x))
        requested_tiles_right = ceil(abs(base.position.x - bound_right) / (base.texture.size.x * stage_scale.x))

    if tile.y == 1:
        requested_tiles_top = ceil(abs(base.position.y - bound_top) / (base.texture.size.y * stage_scale.y))
        requested_tiles_bottom = ceil(abs(base.position.y - bound_bottom) / (base.texture.size.y * stage_scale.y))

    for i in range(requested_tiles_left):
        var tile = base.duplicate()
        tile.position.x = base.position.x - (tilespacing.x + base.texture.size.x * stage_scale.x * (i + 1))
        add_child(tile)

    for i in range(requested_tiles_right):
        var tile = base.duplicate()
        tile.position.x = base.position.x + (tilespacing.x + base.texture.size.x * stage_scale.x * (i + 1))
        add_child(tile)

    for i in range(requested_tiles_top):
        var tile = base.duplicate()
        tile.position.y = base.position.y - (tilespacing.y + base.texture.size.y * stage_scale.y * (i + 1))
        add_child(tile)

    for i in range(requested_tiles_bottom):
        var tile = base.duplicate()
        tile.position.y = base.position.y + (tilespacing.y + base.texture.size.y * stage_scale.y * (i + 1))
        add_child(tile)

func create_mesh(image):
    texture = ImageTexture.new()
    texture.create_from_image(image, 0)

    mesh = MeshInstance2D.new()
    mesh.texture = texture

func update_mesh(camera):
    if not texture:
        return

    var size: Vector2 = texture.size * stage_scale
    var camera_pos = camera.get_camera_position()
    var automatic_offset: float = camera_pos.x * delta.x
    var required_top_offset: float = camera_pos.x * delta.x * top_xscale
    var required_bottom_offset: float = camera_pos.x * delta.x * bottom_xscale

    var applied_top_xscale = required_top_offset - automatic_offset
    var applied_bottom_xscale = required_bottom_offset - automatic_offset

    st.clear()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    # First triangle
    st.add_uv(Vector2(1, 0)) # Top Left
    st.add_vertex(Vector3(0 + applied_top_xscale, 0, 0))
    st.add_uv(Vector2(0, 0)) # Top Right
    st.add_vertex(Vector3(size.x + applied_top_xscale, 0, 0))
    st.add_uv(Vector2(0, 1)) # Bottom Right
    st.add_vertex(Vector3(size.x + applied_bottom_xscale, size.y, 0))
    # Second triangle
    st.add_uv(Vector2(1, 0)) # Top Left
    st.add_vertex(Vector3(0 + applied_top_xscale, 0, 0))
    st.add_uv(Vector2(1, 1)) # Bottom Left
    st.add_vertex(Vector3(0 + applied_bottom_xscale, size.y, 0))
    st.add_uv(Vector2(0, 1)) # Bottom Right
    st.add_vertex(Vector3(size.x + applied_bottom_xscale, size.y, 0))

    mesh.mesh = st.commit()

func handle_camera_update(stage):
    update_mesh(stage.camera)