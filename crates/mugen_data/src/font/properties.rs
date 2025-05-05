use crate::types::Color;

use super::font::Font;

#[derive(Debug, Copy, Clone, Default)]
pub struct GlyphSpacing {
    pub h_advance: f32,
    pub h_side_bearing: f32,
    pub kern: f32,
}

#[derive(Debug, Copy, Clone, Default)]
pub struct FontSpacing {
    pub descent: f32,
    pub ascent: f32,
    pub line_gap: f32,
    pub height: f32
}

pub struct TextStyle {
    pub font: Font,
    pub font_size: i32,
    pub color: Color
}
