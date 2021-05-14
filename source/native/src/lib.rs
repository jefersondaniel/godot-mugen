use gdnative::prelude::*;
mod expression;

// Function that registers all exposed classes to Godot
fn init(handle: InitHandle) {
    handle.add_class::<expression::mugen_expression::MugenExpression>();
}

// Macro that creates the entry-points of the dynamic library.
godot_init!(init);
