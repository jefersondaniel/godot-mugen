use super::{vector_font::VectorFont, bitmap_font::BitmapFont};

#[derive(Clone, Debug)]
pub enum Font {
    None,
    VectorFont {
        font: VectorFont
    },
    BitmapFont {
        font: BitmapFont
    },
}
