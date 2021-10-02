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
var yscalestart: float = 100
var yscaledelta: float = 1

var stage_scale: Vector2 = Vector2(1, 1)
var tile_boxes: Array = [] # Each item is a Rect2
var mesh: MeshInstance2D
var texture: ImageTexture
var st: SurfaceTool

func setup(stage):
    st = SurfaceTool.new()

    stage_scale = constants.get_scale(stage.definition.stageinfo_localcoord)
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

    mesh.position = (start - offset)
    mesh.position = stage_scale * mesh.position

    create_tiles(stage)
    update_mesh(stage)

    if trans == 'addalpha':
        # TODO: Implement alpha.y value
        mesh.modulate = Color(1, 1, 1, alpha.x / 256)

    add_child(mesh)

func create_tiles(stage):
    var size: Vector2 = texture.size * stage_scale
    var requested_tiles_top: int = tile.y
    var requested_tiles_left: int = tile.x
    var requested_tiles_right: int = tile.x
    var requested_tiles_bottom: int = tile.y
    var bound_left = stage.get_bound_left()
    var bound_right = stage.get_bound_right()
    var bound_top = stage.get_bound_top()
    var bound_bottom = stage.get_bound_bottom()

    if tile.x == 1:
        requested_tiles_left = ceil(abs(mesh.position.x - bound_left) / size.x)
        requested_tiles_right = ceil(abs(mesh.position.x - bound_right) / size.x)

    if tile.y == 1:
        requested_tiles_top = ceil(abs(mesh.position.y - bound_top) / size.y)
        requested_tiles_bottom = ceil(abs(mesh.position.y - bound_bottom) / size.y)

    for tile_x in range(requested_tiles_left + requested_tiles_right + 1):
        for tile_y in range(requested_tiles_top + requested_tiles_bottom + 1):
            tile_boxes.append(Rect2(
                (tilespacing.x + size.x * tile_x) - (requested_tiles_left * size.x),
                (tilespacing.y + size.y * tile_y) - (requested_tiles_top * size.x),
                size.x,
                size.y
            ))

func create_mesh(image):
    texture = ImageTexture.new()
    texture.create_from_image(image, 0)

    mesh = MeshInstance2D.new()
    mesh.texture = texture

func update_mesh(stage):
    if not texture:
        return

    var camera_pos = stage.get_camera_relative_position()
    var automatic_offset: float = camera_pos.x * delta.x
    var required_top_offset: float = automatic_offset * top_xscale
    var required_bottom_offset: float = automatic_offset * bottom_xscale
    var applied_top_xscale: float = required_top_offset - automatic_offset
    var applied_bottom_xscale: float = required_bottom_offset - automatic_offset

    st.clear()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)

    for box in tile_boxes:
        # First triangle
        st.add_uv(Vector2(1, 0)) # Top Left
        st.add_vertex(Vector3(box.position.x - applied_top_xscale, box.position.y, 0))
        st.add_uv(Vector2(0, 0)) # Top Right
        st.add_vertex(Vector3(box.position.x + box.size.x - applied_top_xscale, box.position.y, 0))
        st.add_uv(Vector2(0, 1)) # Bottom Right
        st.add_vertex(Vector3(box.position.x + box.size.x - applied_bottom_xscale, box.position.y + box.size.y, 0))
        # Second triangle
        st.add_uv(Vector2(1, 0)) # Top Left
        st.add_vertex(Vector3(box.position.x - applied_top_xscale, box.position.y, 0))
        st.add_uv(Vector2(1, 1)) # Bottom Left
        st.add_vertex(Vector3(box.position.x - applied_bottom_xscale, box.position.y + box.size.y, 0))
        st.add_uv(Vector2(0, 1)) # Bottom Right
        st.add_vertex(Vector3(box.position.x + box.size.x - applied_bottom_xscale, box.position.y + box.size.y, 0))

    mesh.mesh = st.commit()

func handle_camera_update(stage):
    update_mesh(stage)