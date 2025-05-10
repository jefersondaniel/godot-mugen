shader_type canvas_item;

uniform sampler2D palette;
uniform int use_palette = 0;
uniform int blend_type = 0;
uniform float blend_source = 1;
uniform float blend_destination = 1;

void fragment() {
    float r = texture(TEXTURE, UV).r;
    ivec2 pallete_size = textureSize(palette, 0);
    vec4 source_color = texture(TEXTURE, UV);

    if (use_palette > 0) {
        source_color = texture(palette, vec2(r * 255.0 / float(pallete_size.x), 0), 0);
    }

    COLOR = source_color;

    if (blend_type == 1 || blend_type == 2) {
        vec3 destination_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;

        if (blend_type == 1) {
            COLOR = vec4(
                destination_color.r * blend_destination + source_color.r * blend_source,
                destination_color.g * blend_destination  + source_color.g * blend_source,
                destination_color.b * blend_destination  + source_color.b * blend_source,
                source_color.a
            );
        } else {
            COLOR = vec4(
                destination_color.r * blend_destination - source_color.r * blend_source,
                destination_color.g * blend_destination  - source_color.g * blend_source,
                destination_color.b * blend_destination  - source_color.b * blend_source,
                source_color.a
            );
        }
    } else {
        COLOR = source_color;
    }
}
