use gdmacro::godot_enum;
use godot::prelude::*;
use anyhow::Result;

use super::game_manager::GameManager;

#[godot_enum]
#[derive(Copy, Clone)]
#[derive(GodotConvert)]
#[godot(via = GString)]
pub enum GameState {
    PreStart,
    LoadingConfiguration,
    TitleScreen,
    FatalError,
}

impl GameState {
    pub fn update(&self, _game_manager: &GameManager) -> Result<Option<Self>> {
        match self {
            GameState::PreStart => {
                Ok(Some(GameState::LoadingConfiguration))
            }
            GameState::LoadingConfiguration => Ok(None),
            _ => Err(anyhow::anyhow!("Invalid game state"))
        }
    }
}
