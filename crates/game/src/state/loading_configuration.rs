use godot::obj::Gd;

use crate::assets::{CoreAssets, TitleScreenData};
use crate::prelude::*;

pub fn start(game_manager: &mut GameManager) -> Result<()> {
    game_manager.bootstrap();

    if game_manager.configuration_directory.is_empty() {
        return Err(anyhow::anyhow!("Configuration directory does not exist"));
    }

    let configuration_directory = game_manager.configuration_directory.to_string();
    let core_assets = CoreAssets::load(&configuration_directory, game_manager.sprite_cache.clone())?;
    let title_screen = TitleScreenData::build(&core_assets)?;

    game_manager.core_assets = Gd::from_object(core_assets);
    game_manager.title_screen_data = Gd::from_object(title_screen);

    Ok(())
}

pub fn update(game_manager: &mut GameManager) -> Result<Option<GameState>> {
    if game_manager.core_assets.bind().loaded {
        return Ok(Some(GameState::TitleScreen));
    }

    Ok(None)
}
