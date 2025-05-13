use godot::{classes::Shader, prelude::*};

const SHADER_CODE: &str = include_str!("shader.glsl");

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum BlendMode { None, Add, Subtract, PremulAlpha }

pub fn create_sprite_shader(mode: BlendMode) -> Gd<Shader> {
    let mut shader = Shader::new_gd();
    shader.set_code(&GString::from(SHADER_CODE).replace("// blend_placeholder", match mode {
        BlendMode::Add => "render_mode blend_add;",
        BlendMode::Subtract => "render_mode blend_sub;",
        BlendMode::PremulAlpha => "render_mode blend_premul_alpha;",
        BlendMode::None => "",
    }));
    shader
}
