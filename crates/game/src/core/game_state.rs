use gdmacro::godot_enum;
use godot::prelude::*;
use anyhow::Result;

use crate::state::loading_configuration;

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
    pub fn start(&self, game_manager: &mut GameManager) -> Result<()> {
        match self {
            GameState::LoadingConfiguration => loading_configuration::start(game_manager),
            _ => Ok(())
        }
    }

    pub fn update(&self, game_manager: &mut GameManager) -> Result<Option<Self>> {
        match self {
            GameState::PreStart => Ok(Some(GameState::LoadingConfiguration)),
            GameState::LoadingConfiguration => loading_configuration::update(game_manager),
            _ => Ok(None)
        }
    }
}
