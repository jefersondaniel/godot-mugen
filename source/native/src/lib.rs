use gdnative::prelude::*;
mod expressions;
mod fnt;
mod sff;
mod snd;
mod character;

// Function that registers all exposed classes to Godot
fn init(handle: InitHandle) {
    handle.add_class::<expressions::mugen_expression::MugenExpression>();
    handle.add_class::<sff::sff_parser::SffParser>();
    handle.add_class::<snd::snd_parser::SndParser>();
    handle.add_class::<fnt::fnt_parser::FntParser>();
    handle.add_class::<character::user_command_manager::UserCommandManager>();
}

// Macro that creates the entry-points of the dynamic library.
godot_init!(init);
