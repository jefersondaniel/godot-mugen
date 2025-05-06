use godot::prelude::*;
use godot::classes::{Engine, Object};
use prelude::GameManager;

mod helpers;
mod core;
mod state;
mod prelude;

struct GameExtension;

#[gdextension]
unsafe impl ExtensionLibrary for GameExtension {
    fn on_level_init(level: InitLevel) {
        if level == InitLevel::Scene {
            // The `&str` identifies your singleton and can be
            // used later to access it.
            Engine::singleton().register_singleton(
                "GameManager",
                &GameManager::new_alloc(),
            );
        }
    }

    fn on_level_deinit(level: InitLevel) {
        if level == InitLevel::Scene {
            // Let's keep a variable of our Engine singleton instance,
            // and GameManager name.
            let mut engine = Engine::singleton();
            let singleton_name = "GameManager";

            // Here, we manually retrieve our singleton(s) that we've registered,
            // so we can unregister them and free them from memory - unregistering
            // singletons isn't handled automatically by the library.
            if let Some(game_manager) = engine.get_singleton(singleton_name) {
                // Unregistering from Godot, and freeing from memory is required
                // to avoid memory leaks, warnings, and hot reloading problems.
                engine.unregister_singleton(singleton_name);
                game_manager.free();
            } else {
                // You can either recover, or panic from here.
                godot_error!("Failed to get singleton");
            }
        }
    }
}

#[derive(GodotClass)]
#[class(init, base=Object)]
struct HelloWorld {
    base: Base<Object>
}

#[godot_api]
impl HelloWorld {
    #[func]
    fn trigger_signal(&mut self) {
        self.base_mut().emit_signal("some_signal", &[]);
    }

    #[signal]
    fn some_signal();
}
