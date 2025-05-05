use godot::prelude::*;
use godot::classes::Object;

struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}

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