use godot::{classes::Shader, prelude::*};

const SHADER_CODE: &str = include_str!("shader.glsl");

pub fn create_shader() -> Gd<Shader> {
    let mut shader = Shader::new_gd();
    shader.set_code(&GString::from(SHADER_CODE));
    shader
}
