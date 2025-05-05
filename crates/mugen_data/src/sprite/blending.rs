use std::{io::{Error, ErrorKind}, fmt::Display};

use enumflags2::make_bitflags;
use log::warn;

use crate::{enumerations::BlendType, regex::{RegEx, RegExFlags}, attribute_value::{ParseAttributeValue, AttributeValue}};

#[derive(Clone, Copy, Default, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct Blending {
    blend_type: BlendType,
    source: u8,
    destination: u8,
}

impl Blending {
    pub fn new(
        blend_type: BlendType,
        source: u8,
        destination: u8
    ) -> Self {
        Blending {
            blend_type: blend_type,
            source: if blend_type != BlendType::None { source } else { 0 },
            destination: if blend_type != BlendType::None { destination } else { 0 }
        }
    }

    pub fn is_none(&self) -> bool {
        return self.blend_type == BlendType::None;
    }
}

fn parse_blending(raw_text: &str) -> Result<Blending, Error> {
    let text = raw_text.to_string().trim().to_lowercase();

    if text.is_empty() || "none" == text {
        return Ok(Blending::default());
    }

    if text == "addalpha" {
        return Ok(Blending::new(BlendType::Add, 0, 0));
    }

    if text == "add" || text == "a" {
        return Ok(Blending::new(BlendType::Add, 255, 255));
    }

    if text == "add1" || text == "a1" {
        return Ok(Blending::new(BlendType::Add, 255, 127));
    }

    if text == "subtract" || text == "s" || text == "sub" {
        return Ok(Blending::new(BlendType::Subtract, 255, 255));
    }

    let regex = RegEx::new(r"^as(\d+)d(\d+)$", make_bitflags!(RegExFlags::{IgnoreCase}));

    if let Some(regex_match) = regex.search(&text.to_lowercase()) {
        let source_option = regex_match.get_u16(1);
        let destination_option = regex_match.get_u16(2);

        if let Some(source) = source_option {
            if let Some(destination) = destination_option {
                return Ok(Blending::new(
                    BlendType::Add,
                    source as u8,
                    destination as u8
                ));
            }
        }
    }

    Err(Error::new(ErrorKind::InvalidData, format!("Invalid blending format: {}", text)))
}

impl From<&str> for Blending {
    fn from(raw_text: &str) -> Blending {
        match parse_blending(raw_text) {
            Ok(blending) => blending,
            Err(error) => {
                warn!("{}", error);
                Blending::default()
            }
        }
    }
}

impl ParseAttributeValue for Blending {
    fn parse_attribute_value(value: AttributeValue) -> Result<Blending, Error> {
        parse_blending(&value.to_string())
    }
}

impl Display for Blending {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        if self.blend_type == BlendType::None {
            return f.write_str("");
        }

        if self.blend_type == BlendType::Add && self.source == 0 && self.destination == 0 {
            return f.write_str("addalpha");
        }

        if self.blend_type == BlendType::Add && self.source == 255 && self.destination == 255 {
            return f.write_str("add");
        }

        if self.blend_type == BlendType::Add && self.source == 255 && self.destination == 127 {
            return f.write_str("add1");
        }

        if self.blend_type == BlendType::Subtract && self.source == 255 && self.destination == 255 {
            return f.write_str("sub");
        }

        f.write_str(&format!(
            "{}S{}D{}",
            if self.blend_type == BlendType::Add { "A" } else { "S" },
            self.source,
            self.destination
        ))
    }
}
