use std::{fmt::Display, io::{Error,ErrorKind}};

use crate::attribute_value::{ParseAttributeValue, AttributeValue};

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct SpriteId {
    pub group: i16,
    pub image: i16,
}

impl SpriteId {
    pub const INVALID: SpriteId = SpriteId { group: i16::MIN, image: i16::MIN };
    pub const SMALL_PORTRAIT: SpriteId = SpriteId { group: 9000, image: 0 };

    pub fn new(group: i16, image: i16) -> Self {
        SpriteId { group: group, image: image }
    }
}

impl From<&SpriteId> for String {
    fn from(sprite_id: &SpriteId) -> String {
        format!("{}, {}", sprite_id.group, sprite_id.image)
    }
}

impl Default for SpriteId {
    fn default() -> Self {
        SpriteId::INVALID
    }
}

impl ParseAttributeValue for SpriteId {
    fn parse_attribute_value(value: AttributeValue) -> Result<SpriteId, Error> {
        let pieces  = value.split_values();
        let error = Error::new(ErrorKind::InvalidData, format!("Invalid sprite id format: {}", value.to_string()));

        if pieces.len() == 2 {
            let x = pieces[0].parse::<i16>().map_err(|err| Error::new(ErrorKind::InvalidData, format!("Invalid sprite id: \"{}\". {}", value.to_string(), err)))?;
            let y = pieces[1].parse::<i16>().map_err(|err| Error::new(ErrorKind::InvalidData, format!("Invalid sprite id: \"{}\". {}", value.to_string(), err)))?;

            return Ok(SpriteId::new(x, y));
        }

        Err(error)
    }
}

impl Display for SpriteId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(&String::from(self))
    }
}
