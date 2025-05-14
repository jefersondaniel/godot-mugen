use godot::{classes::ShaderMaterial, prelude::*};
use crate::{assets::TextureGroup, ui::material::create_sprite_material, GameManager};
use mugen_data::sprite::blending::Blending;

pub(super) fn create_material(
    texture_group: &TextureGroup,
    blending: Blending,
    game_manager: &Gd<GameManager>
) -> Gd<ShaderMaterial> {
    let sprite_shaders = &game_manager.bind().sprite_shaders;
    let material = create_sprite_material(&texture_group, sprite_shaders, blending);
    material
}
