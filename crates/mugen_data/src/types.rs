use std::io::{Error, ErrorKind};

use glam::Vec2;

pub type Vector2 = Vec2;

#[derive(Copy, Clone, Default, Debug, PartialEq)]
pub struct Rect2 {
    pub origin: Vector2,
    pub size: Vector2
}

impl Rect2 {
    pub fn new(origin: Vector2, size: Vector2) -> Self {
        Self {
            origin,
            size
        }
    }
}

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Hash)]
pub struct Color {
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub a: u8,
}

impl Color {
    pub fn new(r: u8, g: u8, b: u8, a: u8) -> Color {
        Color { r, g, b, a }
    }

    pub fn empty() -> Color {
        Color {
            r: 0,
            g: 0,
            b: 0,
            a: 255,
        }
    }

    pub fn equal(&self, other: &Color) -> bool {
        self.r == other.r && self.g == other.g && self.b == other.b && self.a == other.a
    }

    pub fn parse_rgb_values(values: &[String]) -> Result<Self, Error> {
        if values.len() != 3 {
            return Err(Error::new(ErrorKind::InvalidData, format!("Invalid RGB color: {:?}", values)));
        }

        let r = values[0].parse::<u8>().map_err(|_| Error::new(ErrorKind::InvalidData, format!("Invalid R element of RGB color: {:?}, color: {:?}", values[0], values)))?;
        let g = values[1].parse::<u8>().map_err(|_| Error::new(ErrorKind::InvalidData, format!("Invalid G element of RGB color: {:?}, color: {:?}", values[1], values)))?;
        let b = values[2].parse::<u8>().map_err(|_| Error::new(ErrorKind::InvalidData, format!("Invalid B element of RGB color: {:?}, color: {:?}", values[2], values)))?;

        Ok(Self { r, g, b, a: 255 })
    }

    pub fn bytes(&self) -> [u8; 4] {
        [self.r, self.g, self.b, self.a]
    }
}
