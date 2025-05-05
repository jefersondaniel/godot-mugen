use std::collections::HashMap;

use thunderdome::Index;

use crate::types::{Vector2, Rect2};

use super::properties::{GlyphSpacing, FontSpacing};

#[derive(Clone, Debug)]
pub struct BitmapFont {
    images: Vec<Index>,
    texture_map: HashMap<char, usize>,
    rect_map: HashMap<char, Rect2>,
    offset_map: HashMap<char, Vector2>,
    spacing_map: HashMap<char, GlyphSpacing>,
    spacing: FontSpacing
}

impl BitmapFont {
    pub fn new(images: Vec<Index>, spacing: FontSpacing) -> Self {
        Self {
            images,
            texture_map: HashMap::new(),
            rect_map: HashMap::new(),
            spacing_map: HashMap::new(),
            offset_map: HashMap::new(),
            spacing
        }
    }

    pub fn add_image(&mut self, image: Index) {
        self.images.push(image);
    }

    pub fn add_character(
        &mut self,
        character: char,
        texture_index: usize,
        rect: Rect2,
        offset: Vector2,
        spacing: GlyphSpacing,
    ) {
        self.texture_map.insert(character, texture_index);
        self.rect_map.insert(character, rect);
        self.spacing_map.insert(character, spacing);
        self.offset_map.insert(character, offset);
    }

    pub fn get_glyph_spacing(&self, current: char) -> GlyphSpacing {
        let default = GlyphSpacing::default();
        let result = self.spacing_map.get(&current).unwrap_or(&default);

        *result
    }

    pub fn get_font_spacing(&self) -> FontSpacing {
        self.spacing
    }

    pub fn get_char_source_rect(&self, current: char) -> Rect2 {
        let default = Rect2::default();
        let result = self.rect_map.get(&current).unwrap_or(&default);

        *result
    }

    pub fn get_char_dest_rect(&self, current: char) -> Rect2 {
        let default_rect = Rect2::default();
        let result = *self.rect_map.get(&current).unwrap_or(&default_rect);
        let offset = *self.offset_map.get(&current).unwrap_or(&default_rect.origin);

        Rect2::new(offset, result.size)
    }

    pub fn get_texture(&self, current: char) -> Option<Index> {
        match self.texture_map.get(&current) {
            Some(texture_index) => { Some(
                self.images[*texture_index].clone()
            ) },
            None => { None }
        }
    }
}
