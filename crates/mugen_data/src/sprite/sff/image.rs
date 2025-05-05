use thunderdome::Index;

use crate::types::Color;

#[derive(Clone, Debug)]
pub struct Palette {
    pub colors: Vec<Color>,
}

impl Palette {
    pub fn new(num_colors: usize) -> Palette {
        let colors = vec![Color::empty(); num_colors];
        Palette { colors }
    }

    pub fn from_colors(colors: Vec<Color>) -> Palette {
        Palette { colors }
    }

    pub fn is_empty(&self) -> bool {
        self.colors.is_empty()
    }

    pub fn equal(&self, other: &Palette) -> bool {
        if self.colors.len() != other.colors.len() {
            return false;
        }

        for (i, color) in self.colors.iter().enumerate() {
            if !color.equal(&other.colors[i]) {
                return false;
            }
        }

        true
    }

    pub fn get_color_at(&self, index: usize) -> Color {
        self.colors[index]
    }

    pub fn get_pixels(&self) -> Vec<u8> {
        let width: usize = self.colors.len();
        let mut bytes: Vec<u8> = Vec::with_capacity(width * 4);

        for color in self.colors.iter() {
            bytes.push(color.r);
            bytes.push(color.g);
            bytes.push(color.b);
            bytes.push(color.a);
        }

        bytes
    }

    pub fn len(&self) -> usize {
        self.colors.len()
    }
}

#[derive(Clone, Debug)]
pub struct Image {
    pub width: usize,
    pub height: usize,
    pub pixels: Vec<u8>,
    pub palette: Index,
}

impl Image {
    pub fn new(width: usize, height: usize, pixels: Vec<u8>, palette: Index) -> Image {
        Image { width, height, pixels, palette }
    }

    pub fn empty() -> Image {
        let pixels = Vec::new();

        // Pass in a reference to palette with the correct lifetime
        Image::new(0, 0, pixels, Index::DANGLING)
    }

    pub fn with_palette(&self, palette: Index) -> Image {
        Image::new(self.width, self.height, self.pixels.clone(), palette)
    }
}
