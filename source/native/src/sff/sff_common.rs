use crate::sff::image::{Palette, RawColor, RawImage};
use gdnative::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

#[derive(Clone)]
pub struct SffPal {
    pub pal: Rc<Palette>,
    pub itemno: i32,
    pub groupno: i32,
    pub is_used: bool,
    pub usedby: i32,
    pub reserved: i32,
}

#[derive(Clone)]
pub struct SffData {
    pub image: Rc<RefCell<RawImage>>,
    pub groupno: i32,
    pub imageno: i32,
    pub x: i32,
    pub y: i32,
    pub palindex: i32,
    pub linked: i32,
}

#[derive(Copy, Clone)]
pub struct SffReference {
    pub groupno: i16,
    pub imageno: i16
}

#[derive(Clone)]
pub struct SffMetadata {
    pub major_version: i32,
    pub images: Vec<SffReference>,
}

impl ToVariant for SffMetadata {
    fn to_variant(&self) -> Variant {
        let result = Dictionary::new();
        let images = Dictionary::new();

        for item in self.images.iter() {
            let key = format!("{}-{}", item.groupno, item.imageno);
            images.insert(key, true);
        }

        result.insert("images", images);
        result.insert("major_version", self.major_version);

        result.into_shared().to_variant()
    }
}

pub fn export_palette(source: Rc<Palette>) -> ColorArray {
    let mut result = ColorArray::new();

    for raw_color in source.colors.iter() {
        result.push(Color::rgba(
            raw_color.r as f32 / 255.0,
            raw_color.g as f32 / 255.0,
            raw_color.b as f32 / 255.0,
            raw_color.a as f32 / 255.0,
        ))
    }

    result
}

pub fn import_palette(source: ColorArray) -> Rc<Palette> {
    let mut raw_colors: Vec<RawColor> = Vec::new();

    for i in 0..source.len() {
        let color = source.get(i);

        raw_colors.push(RawColor::new(
            (color.r * 255.0) as u8,
            (color.g * 255.0) as u8,
            (color.b * 255.0) as u8,
            (color.a * 255.0) as u8,
        ))
    }

    Rc::new(Palette::from_colors(raw_colors))
}
