use godot::prelude::*;
use mugen_data::sprite::sff::image::Palette;

#[derive(GodotClass)]
#[class(init, base=RefCounted)]
pub struct PaletteAdapter {
    inner: Palette,
}
