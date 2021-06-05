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
    render_mode blend_add;
    """
}

var material_cache: Dictionary = {}

func get_shader_material(name: String):
    if material_cache.has(name):
        return material_cache[name]

    if not shaders.has(name):
        push_error("shader not found: %s" % [name])
        return null

    var material = ShaderMaterial.new()
    material.shader = Shader.new()
    material.shader.code = shaders[name]
    material_cache[name] = material

    return material_cache[name]
