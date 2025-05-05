use thunderdome::Index;

use crate::types::Vector2;

#[derive(Clone, Copy)]
pub struct SffPal {
    pub pal: Index,
    pub itemno: i32,
    pub groupno: i32,
    pub is_used: bool,
    pub usedby: i32,
    pub reserved: i32,
}

#[derive(Clone, Copy, Debug)]
pub struct SffData {
    pub image: Index,
    pub groupno: i16,
    pub imageno: i16,
    pub x: i16,
    pub y: i16,
    pub palindex: i16,
    pub linked: i16,
}

#[derive(Clone, Copy, Debug)]
pub struct SffMetadata {
    pub verlo3: u8,
    pub verlo2: u8,
    pub verlo1: u8,
    pub verhi: u8,
}

impl SffData {
    pub fn offset(&self) -> Vector2 {
        return Vector2::new(-self.x as f32, -self.y as f32)
    }
}
