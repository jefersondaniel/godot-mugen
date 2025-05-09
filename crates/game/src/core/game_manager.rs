use godot::prelude::*;

use crate::assets::{CoreAssets, SpriteCache, TitleScreenData};

use super::game_state::GameState;

#[derive(GodotClass)]
#[class(init, base=Object)]
pub struct GameManager {
    base: Base<Object>,

    #[var(set, get)]
    pub configuration_directory: GString,

    #[var(get)]
    pub state: GameState,

    #[var(get)]
    pub error_message: GString,

    #[var(get)]
    pub sprite_cache: Gd<SpriteCache>,

    #[var(get)]
    pub core_assets: Gd<CoreAssets>,

    #[var(get)]
    pub title_screen_data: Gd<TitleScreenData>,
}

#[godot_api]
impl GameManager {
    #[signal]
    pub fn state_changed(state: GameState);

    fn set_state(&mut self, state: GameState) {
        self.state = state;
        self.base_mut().emit_signal("state_changed", &[Variant::from(state)]);
    }

    #[func]
    pub fn update(&mut self) {
        let state = self.state;
        let next_state = state.update(self);

        if let Err(error) = next_state {
            self.error_message = format!("{}", error).into();
            self.set_state(GameState::FatalError);
            return;
        }

        if let Ok(Some(state)) = next_state {
            if let Err(error) = state.start(self) {
                self.error_message = format!("{}", error).into();
                self.set_state(GameState::FatalError);
                return;
            }
            self.set_state(state);
        }
    }
}
