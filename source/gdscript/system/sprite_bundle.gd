var images: Dictionary = {}

func _init(images):
    if not images:
        return
    self.images = images

func get_image(path: Array):
    var key = "%s-%s" % [path[0], path[1]]

    if not images.has(key):
        push_error("Missing image: %s" % [key])
        return null

    return self.images[key]

func create_texture(image: Dictionary, flags: int = 0):
    var texture = ImageTexture.new()
    texture.create_from_image(image["image"], 0)
    return texture

func create_empty_texture():
    var empty_image = Image.new()
    var empty_texture = ImageTexture.new()
    empty_image.create_from_data(1, 1, false, Image.FORMAT_RGBA8, PoolByteArray([0,0,0,0]))
    empty_texture.create_from_image(empty_image, 0)
    return empty_texture

func create_sprite(path: Array):
    var image = self.get_image(path)
    var texture = self.create_texture(image)
    var sprite = Sprite.new()
    sprite.texture = texture
    sprite.offset -= Vector2(image["x"], image["y"])

    return sprite
