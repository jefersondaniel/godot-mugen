use glam::Vec2;
use std::io::{Error, ErrorKind};
use crate::types::{Color, Rect2, Vector2};

use super::enumerations::BackgroundLayer;

#[derive(Default, Debug, Clone, PartialEq)]
pub struct AttributeValue {
    value: String,
}

impl AttributeValue {
    pub fn new(
        value: &str,
    ) -> Self {
        AttributeValue {
            value: String::from(value)
        }
    }

    pub fn compare(&self, value: &str, index_a: usize, index_b: usize, length: usize) -> bool {
        let value_a = self.to_string().to_lowercase();
        let value_b = value.to_lowercase();

        value_a[index_a..(index_a + length)] == value_b[index_b..(index_b + length)]
    }

    pub fn to_string(&self) -> String {
        let mut value = self.value.clone();
        if value.len() >= 2 && value.starts_with('"') && value.ends_with('"') {
            value = value[1..(value.len() - 1)].to_string();
        }
        value
    }

    pub fn split_values(&self) -> Vec<String> {
        self.split_with_separator(',', true)
    }

    pub fn split_with_separator(&self, separator: char, trim: bool) -> Vec<String> {
        let text_raw = &self.value.to_string();
        let text = if trim { text_raw.trim() } else { &text_raw };
        let mut result: Vec<String> = Vec::new();
        for raw_item in text.split(separator) {
            let item = if trim { raw_item.trim().to_string() } else { raw_item.to_string() };
            result.push(item);
        }
        result
    }
}

pub trait ParseAttributeValue: Sized {
    fn parse_attribute_value(value: AttributeValue) -> Result<Self, Error>;
}

impl ParseAttributeValue for AttributeValue {
    fn parse_attribute_value(value: AttributeValue) -> Result<AttributeValue, Error> {
        Ok(value)
    }
}

impl ParseAttributeValue for Color {
    fn parse_attribute_value(value: AttributeValue) -> Result<Color, Error> {
        let pieces: Vec<String>  = value.split_values();

        if pieces.len() == 3 || pieces.len() == 4 {
            let r = pieces[0].parse::<u8>().map_err(|err| Error::new(ErrorKind::InvalidData, format!("Invalid color: \"{}\". {}", value.to_string(), err)))?;
            let g = pieces[1].parse::<u8>().map_err(|err| Error::new(ErrorKind::InvalidData, format!("Invalid color: \"{}\". {}", value.to_string(), err)))?;
            let b = pieces[2].parse::<u8>().map_err(|err| Error::new(ErrorKind::InvalidData, format!("Invalid color: \"{}\". {}", value.to_string(), err)))?;
            let a: u8 = if pieces.len() == 4 {
                pieces[3].parse::<u8>().map_err(|err| Error::new(ErrorKind::InvalidData, format!("Invalid color: \"{}\". {}", value.to_string(), err)))?
            } else {
                255
            };

            return Ok(Color::new(r, g, b, a));
        }

        Err(Error::new(ErrorKind::InvalidData, format!("Invalid color: \"{}\". It should contain three comma separated integers.", value.to_string())))
    }
}

impl ParseAttributeValue for String {
    fn parse_attribute_value(value: AttributeValue) -> Result<String, Error> {
        Ok(value.to_string())
    }
}

impl ParseAttributeValue for i32 {
    fn parse_attribute_value(value: AttributeValue) -> Result<i32, Error> {
        let text = value.to_string();

        match text.parse::<i32>() {
            Ok(value) => Ok(value),
            Err(err) => Err(Error::new(ErrorKind::InvalidData, format!("Invalid integer: \"{}\". {}", text, err)))
        }
    }
}

impl ParseAttributeValue for usize {
    fn parse_attribute_value(value: AttributeValue) -> Result<usize, Error> {
        let text = value.to_string();

        match text.parse::<usize>() {
            Ok(value) => Ok(value),
            Err(err) => Err(Error::new(ErrorKind::InvalidData, format!("Invalid index: \"{}\". {}", text, err)))
        }
    }
}

impl ParseAttributeValue for f32 {
    fn parse_attribute_value(value: AttributeValue) -> Result<f32, Error> {
        let text = value.to_string();

        match text.parse::<f32>() {
            Ok(value) => Ok(value),
            Err(err) => Err(Error::new(ErrorKind::InvalidData, format!("Invalid float: \"{}\". {}", text, err)))
        }
    }
}

impl ParseAttributeValue for bool {
    fn parse_attribute_value(value: AttributeValue) -> Result<bool, Error> {
        let text = value.to_string();

        if text.trim() == "1" {
            return Ok(true);
        }

        if text.trim() == "0" {
            return Ok(false);
        }

        return Err(Error::new(ErrorKind::InvalidData, format!("Invalid bool: {}", text)));
    }
}

impl ParseAttributeValue for Vec2 {
    fn parse_attribute_value(value: AttributeValue) -> Result<Vec2, Error> {
        let pieces  = value.split_values();

        if pieces.len() == 2 {
            let x = pieces[0].parse::<i32>().map_err(|err| Error::new(ErrorKind::InvalidData, format!("Invalid vector: \"{}\". {}", value.to_string(), err)))?;
            let y = pieces[1].parse::<i32>().map_err(|err| Error::new(ErrorKind::InvalidData, format!("Invalid vector: \"{}\". {}", value.to_string(), err)))?;

            return Ok(Vec2::new(x as f32, y as f32));
        }

        Err(Error::new(ErrorKind::InvalidData, format!("Invalid vector: \"{}\". It should contain two comma separated integers.", value.to_string())))
    }
}

impl ParseAttributeValue for Rect2 {
    fn parse_attribute_value(value: AttributeValue) -> Result<Rect2, Error> {
        let pieces  = value.split_values();

        if pieces.len() > 3 {
            let x1 = pieces[0].parse::<f32>()
                .map_err(
                    |err| Error::new(ErrorKind::InvalidData, format!("Invalid rect: \"{}\". {}", value.to_string(), err))
                )?;

            let y1 = pieces[1].parse::<f32>()
                .map_err(
                    |err| Error::new(ErrorKind::InvalidData, format!("Invalid rect: \"{}\". {}", value.to_string(), err))
                )?;

            let x2 = pieces[2].parse::<f32>()
                .map_err(
                    |err| Error::new(ErrorKind::InvalidData, format!("Invalid rect: \"{}\". {}", value.to_string(), err))
                )?;

            let y2 = pieces[3].parse::<f32>()
                .map_err(
                    |err| Error::new(ErrorKind::InvalidData, format!("Invalid rect: \"{}\". {}", value.to_string(), err))
                )?;

            return Ok(
                Rect2::new(
                    Vector2::new(x1, y1),
                    Vector2::new(x2 - x1, y2 - y1),
                )
            );
        }

        Err(Error::new(ErrorKind::InvalidData, format!("Invalid rect: {}", value.to_string())))
    }
}

impl ParseAttributeValue for BackgroundLayer {
    fn parse_attribute_value(value: AttributeValue) -> Result<BackgroundLayer, Error> {
        let value  = value.to_string();

        if value.trim() == "0" {
            return Ok(BackgroundLayer::Back);
        }

        if value.trim() == "1" {
            return Ok(BackgroundLayer::Front);
        }

        Err(Error::new(ErrorKind::InvalidData, format!("Invalid layer: {}", value)))
    }
}
