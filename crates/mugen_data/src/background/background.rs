use std::io::Error;

use crate::text::text_section::TextSection;

use super::{background_type::BackgroundType, static_background::StaticBackground};

#[derive(Clone, Debug)]
pub enum Background {
    None,
    Static(StaticBackground),
}

impl Default for Background {
    fn default() -> Self {
        Self::None
    }
}

impl Background {
    pub fn from_text_section(section: &TextSection) -> Result<Self, Error> {
        let background_type = section.get_attribute_or_default("type");

        match background_type {
            BackgroundType::Static => Ok(Background::Static(StaticBackground::from_text_section(&section))),
            _ => Ok(Background::None),
        }
    }
}
