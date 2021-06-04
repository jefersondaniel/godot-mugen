use gdnative::api::image::Image;
use gdnative::prelude::*;
use std::rc::Rc;

#[derive(Copy, Clone)]
pub struct RawColor {
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub a: u8,
}

impl RawColor {
    pub fn new(r: u8, g: u8, b: u8, a: u8) -> RawColor {
        RawColor { r, g, b, a }
    }

    pub fn empty() -> RawColor {
        RawColor {
            r: 0,
            g: 0,
            b: 0,
            a: 255,
        }
    }

    pub fn equal(&self, other: &RawColor) -> bool {
        self.r == other.r && self.g == other.g && self.b == other.b && self.a == other.a
    }
}

#[derive(Clone)]
pub struct Palette {
    pub colors: Vec<RawColor>,
}

impl Palette {
    pub fn new(num_colors: usize) -> Palette {
        let colors = vec![RawColor::empty(); num_colors];
        Palette { colors }
    }

    pub fn from_colors(colors: Vec<RawColor>) -> Palette {
        Palette { colors }
    }

    pub fn is_empty(&self) -> bool {
        self.colors.is_empty()
    }

    pub fn equal(&self, other: &Palette) -> bool {
        if self.colors.len() != other.colors.len() {
            return false;
        }

        for (i, color) in self.colors.iter().enumerate() {
            if !color.equal(&other.colors[i]) {
                return false;
            }
        }

        true
    }
}

#[derive(Clone)]
pub struct RawImage {
    pub w: usize,
    pub h: usize,
    pub pixels: Rc<Vec<u8>>,
    pub color_table: Rc<Palette>,
}

impl RawImage {
    pub fn empty() -> RawImage {
        let pixels = Rc::new(Vec::new());
        let color_table = Rc::new(Palette::new(0));

        RawImage {
            w: 0,
            h: 0,
            pixels,
            color_table,
        }
    }

    pub fn create_image(&self) -> Ref<Image, Unique> {
        let mut my_byte_array: Vec<u8> = Vec::with_capacity(self.w * self.h * 4);

        for &pixel in self.pixels.iter() {
            let color = &self.color_table.colors[pixel as usize];
            my_byte_array.push(color.r);
            my_byte_array.push(color.g);
            my_byte_array.push(color.b);
            my_byte_array.push(color.a);
        }

        let dest = ByteArray::from_slice(my_byte_array.as_slice());

        let image = Image::new();
        image.create_from_data(
            self.w as i64,
            self.h as i64,
            false,
            Image::FORMAT_RGBA8,
            dest,
        );
        image
    }
}
