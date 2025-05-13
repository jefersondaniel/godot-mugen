shader_type canvas_item;
// blend_placeholder

uniform sampler2D palette : filter_nearest;
uniform int use_palette = 0;
uniform int use_alpha_override = 0;
uniform float alpha_override = 0;

void fragment() {
    float r = texture(TEXTURE, UV).r;
    ivec2 pallete_size = textureSize(palette, 0);
    vec4 sprite_texture_color = texture(TEXTURE, UV);
    if (use_palette > 0) {
        sprite_texture_color = texture(palette, vec2(r * 255.0 / float(pallete_size.x), 0), 0);
    }
    if (use_alpha_override > 0) {
       sprite_texture_color.a = alpha_override;
    }
    COLOR = sprite_texture_color;
}
