use godot::obj::Gd;

use crate::assets::CoreAssets;
use crate::prelude::*;

pub fn start(game_manager: &mut GameManager) -> Result<()> {
    if game_manager.configuration_directory.is_empty() {
        return Err(anyhow::anyhow!("Configuration directory does not exist"));
    }

    let configuration_directory = game_manager.configuration_directory.to_string();
    let core_assets = Gd::from_object(CoreAssets::load(&configuration_directory, game_manager.sprite_cache.clone())?);
    game_manager.core_assets = Some(core_assets);

    Ok(())
}

pub fn update(game_manager: &mut GameManager) -> Result<Option<GameState>> {
    if game_manager.core_assets.is_some() {
        return Ok(Some(GameState::TitleScreen));
    }

    Ok(None)
}
