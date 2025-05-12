shader_type canvas_item;

uniform sampler2D palette : filter_nearest;
uniform int use_palette = 0;

void fragment() {
    float r = texture(TEXTURE, UV).r;
    ivec2 pallete_size = textureSize(palette, 0);
    vec4 sprite_texture_color = texture(TEXTURE, UV);
    if (use_palette > 0) {
        sprite_texture_color = texture(palette, vec2(r * 255.0 / float(pallete_size.x), 0), 0);
    }
    COLOR = sprite_texture_color;
}
