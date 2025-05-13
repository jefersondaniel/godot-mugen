use std::collections::HashMap;

use godot::{classes::{Engine, Shader}, prelude::*};

use crate::assets::{CoreAssets, SpriteCache, TitleScreenData};

use super::{game_state::GameState, shader::{create_sprite_shader, BlendMode}};

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

    pub sprite_shaders: HashMap<BlendMode, Gd<Shader>>,
}

#[godot_api]
impl GameManager {
    pub fn singleton() -> Gd<Self> {
        let name = StringName::from("GameManager");
        Engine::singleton().get_singleton(&name).unwrap().cast::<GameManager>()
    }

    pub fn bootstrap(&mut self) {
        self.sprite_shaders = HashMap::new();
        self.sprite_shaders.insert(BlendMode::None, create_sprite_shader(BlendMode::None));
        self.sprite_shaders.insert(BlendMode::Add, create_sprite_shader(BlendMode::Add));
        self.sprite_shaders.insert(BlendMode::Subtract, create_sprite_shader(BlendMode::Subtract));
        self.sprite_shaders.insert(BlendMode::PremulAlpha, create_sprite_shader(BlendMode::PremulAlpha));
    }

    #[signal]
    pub fn state_changed(state: GameState);

    fn set_state(&mut self, state: GameState) {
        self.state = state;
        self.base_mut().emit_signal("state_changed", &[Variant::from(state)]);
    }

    #[func]
    pub fn get_viewport_size(&self) -> Vector2 {
        let window = Engine::singleton()
            .get_main_loop()
            .unwrap()
            .cast::<SceneTree>()
            .get_root();

        if let Some(window) = window {
            let viewport = window.get_viewport();

            if let Some(viewport) = viewport {
                let rect = viewport.get_visible_rect();
                rect.size
            } else {
                Vector2::new(0.0, 0.0)
            }
        } else {
            Vector2::new(0.0, 0.0)
        }
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
