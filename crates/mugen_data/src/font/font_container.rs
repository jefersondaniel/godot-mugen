use log::warn;

use super::font::Font;

#[derive(Clone, Default, Debug)]
pub struct FontContainer {
    pub font_banks: Vec<Font>,
    pub size: i32,
}

impl FontContainer {
    pub fn get_color_bank(&self, color_bank: usize) -> Font {
        if color_bank >= self.font_banks.len() {
            warn!("Color bank not found: {}. Using default.", color_bank);
            return self.font_banks[0].clone()
        }

        self.font_banks[color_bank].clone()
    }
}

