use godot::{classes::{Shader, ShaderMaterial}, prelude::*};

use crate::assets::TextureGroup;

pub fn create_sprite_material(
    texture_group: &TextureGroup,
    sprite_shader: &Gd<Shader>,
) -> Gd<ShaderMaterial> {
    let mut material = ShaderMaterial::new_gd();
    material.set_shader(sprite_shader);
    material.set_shader_parameter("palette", &Variant::from(texture_group.palette_texture.clone()));
    material.set_shader_parameter("use_palette", &Variant::from(1));
    material
}
