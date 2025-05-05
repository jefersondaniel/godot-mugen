use std::ops::Deref;

use crate::{sprite::sprite_id::SpriteId, text::text_section::TextSection};

use super::base_background::BaseBackground;

#[derive(Clone, Debug)]
pub struct StaticBackground {
    pub base_background: BaseBackground,
    // groupno, imageno specifies the sprite in the SFF to display for this background element
    pub spriteid: SpriteId,
}

impl Deref for StaticBackground {
    type Target = BaseBackground;

    fn deref(&self) -> &Self::Target {
        &self.base_background
    }
}

impl StaticBackground {
    pub fn from_text_section(section: &TextSection) -> Self {
        Self {
            base_background: BaseBackground::from_text_section(section),
            spriteid: section.get_attribute_or_default("spriteno"),
        }
    }
}
