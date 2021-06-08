extends ParallaxLayer

# Default Mugen Fields
var id: int = 0
var type: String = "normal"
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
var window: PoolIntArray = PoolIntArray([])
var windowdelta: Vector2 = Vector2(0, 0)
var actionno: int = 0
var width: Array = []
var top_xscale: float = 1
var bottom_xscale: float = 1
var yscalestart: float = 100
var yscaledelta: float = 1
# Custom Fields
var setup = false
var root: Node2D
var images: Dictionary = {}
var custom_scale: Vector2 = Vector2(1, 1)
var tile_available_size: Vector2 = Vector2(4096, 4096)
var camera_position: Vector2 = Vector2(0, 0)
var mesh: MeshInstance2D
var texture: ImageTexture
var st: SurfaceTool
var tile_boxes: Array = []
var custom_rect = null

func _ready():
    update_custom_rect()
    update_material()

func setup():
    root = Node2D.new()
    st = SurfaceTool.new()
    z_index = layerno
    setup_mesh()

    add_child(root)
    root.add_child(mesh)

func update_custom_rect():
    if window and window.size() == 4:
        window[0] *= custom_scale.x
        window[1] *= custom_scale.x
        window[2] *= custom_scale.x
        window[3] *= custom_scale.x
        var custom_position = Vector2(-global_position.x + window[0], -global_position.y + window[1])
        var custom_size = Vector2(1 + window[2] - window[0], 1 + window[3] - window[1])
        custom_rect = Rect2(custom_position, custom_size)
    else:
        custom_rect = null

func update_material():
    var shader_factory = constants.container["kernel"].shader_factory

    if not trans or trans == "none":
        mesh.material = null
        return

    if trans == "addalpha":
        # TODO: Implement alpha.y value
        mesh.modulate = Color(1, 1, 1, alpha.x / 256)
        return

    mesh.material = shader_factory.get_shader_material(trans)

func setup_mesh():
    var spritekey = '%s-%s' % [spriteno[0], spriteno[1]]

    if not images.has(spritekey):
        printerr("Invalid spriteno: %s,%s" % spriteno)
        return

    var image = images[spritekey]
    var offset = Vector2(image['x'], image['y'])

    create_mesh(image['image'])

    mesh.position = -offset
    mesh.position = custom_scale * mesh.position

    create_tiles()
    update_mesh()

func get_scaled_texture_size() -> Vector2:
    return texture.size * custom_scale

func create_tiles():
    var size: Vector2 = get_scaled_texture_size()
    var requested_tiles_top: int = 0
    var requested_tiles_left: int = 0
    var requested_tiles_right: int = tile.x
    var requested_tiles_bottom: int = tile.y
    var bound_left = -tile_available_size.x / 2
    var bound_right = tile_available_size.x / 2
    var bound_top = -tile_available_size.y / 2
    var bound_bottom = tile_available_size.y / 2

    if tile.x == 1:
        requested_tiles_left = ceil(abs(mesh.position.x - bound_left) / size.x)
        requested_tiles_right = ceil(abs(mesh.position.x - bound_right) / size.x)

    if tile.y == 1:
        requested_tiles_top = ceil(abs(mesh.position.y - bound_top) / size.y)
        requested_tiles_bottom = ceil(abs(mesh.position.y - bound_bottom) / size.y)

    for tile_x in range(max(1, requested_tiles_left + requested_tiles_right)):
        for tile_y in range(max(1, requested_tiles_top + requested_tiles_bottom)):
            tile_boxes.append(Rect2(
                (tilespacing.x + size.x * tile_x) - (requested_tiles_left * size.x),
                (tilespacing.y + size.y * tile_y) - (requested_tiles_top * size.y),
                size.x,
                size.y
            ))

func create_mesh(image):
    texture = ImageTexture.new()
    texture.create_from_image(image, 0)

    mesh = MeshInstance2D.new()
    mesh.texture = texture

func update_mesh():
    if not texture:
        return

    var automatic_offset: float = camera_position.x * delta.x
    var required_top_offset: float = automatic_offset * top_xscale
    var required_bottom_offset: float = automatic_offset * bottom_xscale
    var applied_top_xscale: float = required_top_offset - automatic_offset
    var applied_bottom_xscale: float = required_bottom_offset - automatic_offset

    st.clear()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)

    for box in tile_boxes:
        # First triangle
        st.add_uv(Vector2(0, 0)) # Top Left
        st.add_vertex(Vector3(box.position.x - applied_top_xscale, box.position.y, 0))
        st.add_uv(Vector2(1, 0)) # Top Right
        st.add_vertex(Vector3(box.position.x + box.size.x - applied_top_xscale, box.position.y, 0))
        st.add_uv(Vector2(1, 1)) # Bottom Right
        st.add_vertex(Vector3(box.position.x + box.size.x - applied_bottom_xscale, box.position.y + box.size.y, 0))
        # Second triangle
        st.add_uv(Vector2(0, 0)) # Top Left
        st.add_vertex(Vector3(box.position.x - applied_top_xscale, box.position.y, 0))
        st.add_uv(Vector2(0, 1)) # Bottom Left
        st.add_vertex(Vector3(box.position.x - applied_bottom_xscale, box.position.y + box.size.y, 0))
        st.add_uv(Vector2(1, 1)) # Bottom Right
        st.add_vertex(Vector3(box.position.x + box.size.x - applied_bottom_xscale, box.position.y + box.size.y, 0))

    mesh.mesh = st.commit()

func _physics_process(delta: float):
    root.position.x += velocity.x * constants.TARGET_FPS * delta
    root.position.y += velocity.y * constants.TARGET_FPS * delta

    var texture_size = get_scaled_texture_size()

    if tile.x == 1 and abs(root.position.x) > texture_size.x:
        root.position.x -= root.position.x

    if tile.y == 1 and abs(root.position.y) > texture_size.y:
        root.position.y -= root.position.y

func _draw():
    if custom_rect:
        VisualServer.canvas_item_set_custom_rect(get_canvas_item(), true, custom_rect)
        VisualServer.canvas_item_set_clip(get_canvas_item(), true)
    else:
        VisualServer.canvas_item_set_clip(get_canvas_item(), false)
