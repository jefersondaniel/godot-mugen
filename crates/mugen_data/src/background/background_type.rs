use std::io::{Error, ErrorKind};

use crate::attribute_value::{AttributeValue, ParseAttributeValue};

#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum BackgroundType {
    None,
    Static,
    Parallax,
    Animated
}

impl Default for BackgroundType {
    fn default() -> Self { BackgroundType::None }
}

impl ParseAttributeValue for BackgroundType {
    fn parse_attribute_value(value: AttributeValue) -> Result<BackgroundType, Error> {
        let text  = value.to_string();

        if text.to_lowercase().trim() == "normal" {
            return Ok(BackgroundType::Static);
        }

        if text.to_lowercase().trim() == "parallax" {
            return Ok(BackgroundType::Parallax);
        }

        if text.to_lowercase().trim() == "anim" {
            return Ok(BackgroundType::Animated);
        }

        if text.to_lowercase().trim() == "none" {
            return Ok(BackgroundType::None);
        }

        Err(Error::new(ErrorKind::InvalidData, format!("Invalid background type: {}", text)))
    }
}
