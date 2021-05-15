use gdnative::prelude::*;
use gdnative::api::image::Image;

#[derive(Copy, Clone)]
pub struct RawColor {
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub a: u8,
}

impl RawColor {
    pub fn new(r: u8, g: u8, b: u8, a: u8) -> RawColor {
        RawColor{ r, g, b, a }
    }

    pub fn empty() -> RawColor {
        RawColor{
            r: 0,
            g: 0,
            b: 0,
            a: 255,
        }
    }

    // pub fn rgba(&self) -> u32 {
    //     let mut result: u32 = 0;

    //     result ^= (self.a as u32) << 24;
    //     result ^= (self.b as u32) << 16;
    //     result ^= (self.g as u32) << 8;
    //     result ^= self.r as u32;

    //     return result;
    // }

    pub fn equal(&self, other: &RawColor) -> bool {
        self.r == other.r &&
        self.g == other.g &&
        self.b == other.b &&
        self.a == other.a
    }
}

#[derive(Clone)]
pub struct Palette {
    pub colors: Vec<RawColor>,
}

impl Palette {
    pub fn new(num_colors: usize) -> Palette {
        let mut colors: Vec<RawColor> = Vec::new();
        if num_colors > 0 {
            colors.resize(num_colors, RawColor::empty());
        }
        Palette { colors }
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

        return true;
    }
}

#[derive(Clone)]
pub struct RawImage {
    pub w: usize,
    pub h: usize,
    pub pixels: Vec<u8>,
    pub color_table: Palette,
}

impl RawImage {
    pub fn empty() -> RawImage {
        let pixels = Vec::new();
        let color_table = Palette::new(0);
        RawImage {
            w: 0,
            h: 0,
            pixels,
            color_table,
        }
    }

    pub fn sized(w: usize, h: usize, num_colors: usize) -> RawImage {
        let mut pixels = Vec::new();
        pixels.resize(w * h, 0);
        let color_table = Palette::new(num_colors);
        RawImage {
            w,
            h,
            pixels,
            color_table,
        }
    }

    pub fn set_color(&mut self, index: usize, color: RawColor) {
        self.color_table.colors[index] = color;
    }

    pub fn create_image(&self) -> Ref<Image, Unique> {
        let mut dest = ByteArray::new();
        dest.resize((self.w * self.h * 4) as i32);

        for (i, pixel) in self.pixels.iter().enumerate() {
            let color = self.color_table.colors[*pixel as usize];
            dest.set((4 * i) as i32, color.r);
            dest.set((4 * i + 1) as i32, color.g);
            dest.set((4 * i + 2) as i32, color.b);
            dest.set((4 * i + 3) as i32, color.a);
        }

        let image = Image::new();
        image.create_from_data(
            self.w as i64,
            self.h as i64,
            false,
            Image::FORMAT_RGBA8,
            dest
        );
        image
    }
}
