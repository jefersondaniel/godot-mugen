use godot::prelude::*;
use godot::classes::{Engine, Object};
use prelude::GameManager;

mod adapters;
mod assets;
mod core;
mod helpers;
mod prelude;
mod state;
mod ui;

struct GameExtension;

#[gdextension]
unsafe impl ExtensionLibrary for GameExtension {
    fn on_level_init(level: InitLevel) {
        if level == InitLevel::Scene {
            Engine::singleton().register_singleton(
                "GameManager",
                &GameManager::new_alloc(),
            );
        }
    }

    fn on_level_deinit(level: InitLevel) {
        if level == InitLevel::Scene {
            let mut engine = Engine::singleton();
            let singleton_name = "GameManager";

            if let Some(game_manager) = engine.get_singleton(singleton_name) {
                engine.unregister_singleton(singleton_name);
                game_manager.free();
            } else {
                godot_error!("Failed to get singleton");
            }
        }
    }
}
