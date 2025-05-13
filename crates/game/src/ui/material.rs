use std::collections::HashMap;

use godot::{classes::{Shader, ShaderMaterial}, prelude::*};
use mugen_data::{enumerations::BlendType, sprite::blending::Blending};

use crate::{assets::TextureGroup, core::shader::BlendMode};

pub fn create_sprite_material(
    texture_group: &TextureGroup,
    sprite_shaders: &HashMap<BlendMode, Gd<Shader>>,
    blending: Blending,
) -> Gd<ShaderMaterial> {
    let mut blend_mode = BlendMode::None;

    if blending.blend_type != BlendType::None {
        if blending.blend_type == BlendType::Add && blending.destination == 255 {
            blend_mode = BlendMode::Add;
        } else if blending.blend_type == BlendType::Add && blending.source == 255 {
            blend_mode = BlendMode::PremulAlpha;
        } else if blending.blend_type == BlendType::Subtract && blending.destination == 255 {
            blend_mode = BlendMode::Subtract;
        } else {
            godot_warn!("Unsupported blending: {}", blending);
        }
    }

    let mut material = ShaderMaterial::new_gd();
    material.set_shader(sprite_shaders.get(&blend_mode).unwrap());
    material.set_shader_parameter("palette", &Variant::from(texture_group.palette_texture.clone()));
    material.set_shader_parameter("use_palette", &Variant::from(1));

    if blend_mode != BlendMode::None {
        let mut alpha_override: Option<f32> = None;
        if blending.blend_type == BlendType::Add && blending.destination == 255 {
            alpha_override = Some(blending.source as f32 / 255.0);
        } else if blending.blend_type == BlendType::Add && blending.source == 255 {
            alpha_override = Some(1.0 - (blending.destination as f32 / 255.0));
        } else if blending.blend_type == BlendType::Subtract && blending.destination == 255 {
            alpha_override = Some(blending.source as f32 / 255.0);
        }
        if let Some(alpha_override) = alpha_override {
            material.set_shader_parameter("use_alpha_override", &Variant::from(1));
            material.set_shader_parameter("alpha_override", &Variant::from(alpha_override));
        }
    }

    material
}
