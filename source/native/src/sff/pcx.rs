use gdnative::prelude::*;
use std::cmp;
use std::result::Result;
use crate::sff::image::{ Palette, RawColor, RawImage };
use crate::sff::data::{ DataReader, DataError };

#[allow(dead_code)]
pub struct PcxHeader {
    manufacturer: u8,
    version: u8,
    encoding: u8,
    bpp: u8,
    x_min: u16,
    y_min: u16,
    x_max: u16,
    y_max: u16,
    h_dpi: u16,
    y_dpi: u16,
    color_map: Palette,
    reserved: u8,
    n_planes: u8,
    bytes_per_line: u16,
    palette_info: u16,
    h_screen_size: u16,
    v_screen_size: u16,
}

fn read_color(reader: &mut dyn DataReader) -> RawColor {
    let r = reader.get_u8();
    let g = reader.get_u8();
    let b = reader.get_u8();

    RawColor::new(r, g, b, 255)
}

fn read_palette(reader: &mut dyn DataReader) -> Palette {
    let mut palette = Palette::new(16);

    for i in 0..16 {
        palette.colors[i] = read_color(reader);
    }

    palette
}

impl PcxHeader {
    pub fn width(&self) -> i32 {
        (self.x_max as i32) - (self.x_min as i32) + 1
    }

    pub fn height(&self) -> i32 {
        (self.y_max as i32) - (self.y_min as i32) + 1
    }

    pub fn is_compressed(&self) -> bool {
        self.encoding == 1
    }

    pub fn from(reader: &mut dyn DataReader) -> PcxHeader {
        let manufacturer: u8 = reader.get_u8();
        let version: u8 = reader.get_u8();
        let encoding: u8 = reader.get_u8();
        let bpp: u8 = reader.get_u8();
        let x_min: u16 = reader.get_u16();
        let y_min: u16 = reader.get_u16();
        let x_max: u16 = reader.get_u16();
        let y_max: u16 = reader.get_u16();
        let h_dpi: u16 = reader.get_u16();
        let y_dpi: u16 = reader.get_u16();
        let color_map: Palette = read_palette(reader);
        let reserved: u8 = reader.get_u8();
        let n_planes: u8 = reader.get_u8();
        let bytes_per_line: u16 = reader.get_u16();
        let palette_info: u16 = reader.get_u16();
        let h_screen_size: u16 = reader.get_u16();
        let v_screen_size: u16 = reader.get_u16();

        while reader.pos() < 128 {
            reader.get_u8();
        }

        PcxHeader {
            manufacturer,
            version,
            encoding,
            bpp,
            x_min,
            y_min,
            x_max,
            y_max,
            h_dpi,
            y_dpi,
            color_map,
            reserved,
            n_planes,
            bytes_per_line,
            palette_info,
            h_screen_size,
            v_screen_size
        }
    }
}

fn read_line(reader: &mut dyn DataReader, buf: &mut Vec<u8>, header: &PcxHeader) {
    let size = buf.len();
    let mut i: usize = 0;
    let mut byte: u8;
    let mut count: u8;

    if header.is_compressed() {
        while i < size {
            count = 1;
            byte = reader.get_u8();
            if byte > 0xc0 {
                count = byte - 0xc0;
                byte = reader.get_u8();
            }
            loop {
                // TODO: Review performance
                if i >= size || count <= 0 {
                    break;
                }

                buf[i] = byte;
                count = count - 1;
                i = i + 1;
            }
        }
    } else {
        while i < size {
            byte = reader.get_u8();
            buf[i] = byte;
            i = i + 1;
        }
    }
}

pub fn read_image_1(reader: &mut dyn DataReader, header: &PcxHeader) -> RawImage {
    let mut buf: Vec<u8> = Vec::new();
    buf.resize(header.bytes_per_line as usize, 0);
    let mut img = RawImage::sized(header.width() as usize, header.height() as usize, 2);
    let width = header.width();

    for y in 0..header.height() {
        if reader.eof() {
            return img;
        }

        read_line(reader, &mut buf, header);

        let line_offset: usize = (width * y) as usize;
        let bpl = cmp::min((width + 7) / 8, header.bytes_per_line as i32);
        for x in 0..(bpl as usize) {
            img.pixels[line_offset + x] = buf[x];
        }
    }

    img.set_color(0, RawColor::new(0, 0, 0, 255));
    img.set_color(1, RawColor::new(255, 255, 255, 255));

    img
}

pub fn read_image_4(reader: &mut dyn DataReader, header: &PcxHeader) -> RawImage {
    let mut buf: Vec<u8> = Vec::new();
    buf.resize((header.bytes_per_line * 4) as usize, 0);
    let mut pixbuf: Vec<u8> = Vec::new();
    buf.resize(header.width() as usize, 0);

    let mut img = RawImage::sized(header.width() as usize, header.height() as usize, 16);
    let width = header.width();

    for y in 0..header.height() {
        if reader.eof() {
            return img;
        }

        pixbuf.fill(0);

        read_line(reader, &mut buf, header);

        for i in 0..4 {
            let offset: usize = i * header.bytes_per_line as usize;
            for x in 0..(header.width() as usize) {
                if (buf[offset + (x / 8)] & (128 >> (x % 8))) != 0 {
                    pixbuf[x] = pixbuf[x] + (1 << i);
                }
            }
        }

        let line_offset: usize = (width * y) as usize;

        for x in 0..(header.width() as usize) {
            img.pixels[line_offset + x] = pixbuf[x];
        }
    }

    for i in 0..16 {
        img.set_color(i, header.color_map.colors[i]);
    }

    img
}

pub fn read_image_8(reader: &mut dyn DataReader, header: &PcxHeader) -> RawImage {
    let mut buf: Vec<u8> = Vec::new();
    buf.resize(header.bytes_per_line as usize, 0);
    let mut img = RawImage::sized(header.width() as usize, header.height() as usize, 256);
    let width = header.width();

    for y in 0..header.height() {
        if reader.eof() {
            return img;
        }

        read_line(reader, &mut buf, header);

        let line_offset: usize = (width * y) as usize;
        let bpl: usize = cmp::min(header.bytes_per_line as usize, width as usize);
        for x in 0..bpl {
            img.pixels[line_offset + x] = buf[x];
        }
    }

    let flag: u8 = reader.get_u8();

    if flag == 12 && (header.version == 5 || header.version == 2) {
        for i in 0..256 {
            let r = reader.get_u8();
            let g = reader.get_u8();
            let b = reader.get_u8();
            img.set_color(i, RawColor::new(r, g, b, if i == 0 { 0 } else { 255 }));
        }
    } else {
        godot_print!("error: unsupported pcx, palette not set");
    }

    img
}

pub fn read_image_24(_: &mut dyn DataReader, _: &PcxHeader) -> RawImage {
    godot_print!("error: unsupported 24bit pcx"); // TODO: Add 24bit support

    RawImage::empty()
}

pub fn read_pcx(reader: &mut dyn DataReader) -> Result<RawImage, DataError> {
    if reader.size() < 128 {
        return Result::Err(DataError { message: "Pcx data too small".to_string() });
    }

    let header = PcxHeader::from(reader);

    if header.manufacturer != 10 || reader.eof() {
        return Result::Err(DataError {
            message: format!("error: invalid pcx header: {}", header.manufacturer)
        });
    }

    let mut img: RawImage = RawImage::empty();

    if header.bpp == 1 && header.n_planes == 1 {
        img = read_image_1(reader, &header);
    } else if header.bpp == 1 && header.n_planes == 4 {
        img = read_image_4(reader, &header);
    } else if header.bpp == 8 && header.n_planes == 1 {
        img = read_image_8(reader, &header);
    } else if header.bpp == 8 && header.n_planes == 3 {
        img = read_image_24(reader, &header);
    }

    if img.pixels.len() > 0 {
        return Result::Ok(img);
    }

    Result::Err(DataError { message: "Failed decoding PCX pixels".to_string() })
}
