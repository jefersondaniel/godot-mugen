var shaders = {
    # TODO: Fix add1 shader
    "add1": """
    shader_type canvas_item;
    render_mode blend_add;
    """,
    "add": """
    shader_type canvas_item;
    render_mode blend_add;
    """,
    "sub": """
    shader_type canvas_item;
    render_mode blend_sub;
    """,
    "mix_color": """
    shader_type canvas_item;
    uniform vec4 mix_color : hint_color;
    void fragment(){
        COLOR = texture(TEXTURE, UV);
        COLOR.r = (COLOR.r + mix_color.r) / 2.0;
        COLOR.g = (COLOR.g + mix_color.g) / 2.0;
        COLOR.b = (COLOR.b + mix_color.b) / 2.0;
    }
    """
}

var shader_cache: Dictionary = {}

func get_shader_material(name: String):
    if not shaders.has(name):
        push_error("shader not found: %s" % [name])
        return null

    var shader = shader_cache.get(name, null)

    if not shader:
        shader = Shader.new()
        shader.code = shaders[name]
        shader_cache[name] = shader

    var material = ShaderMaterial.new()
    material.shader = shader

    return material
