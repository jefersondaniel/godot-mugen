use std::cmp;
use std::result::Result;
use std::io::{ErrorKind,Error};
use log::warn;
use thunderdome::{Arena, Index};

use crate::io::reader::DataReader;
use crate::types::Color;
use super::image::{Palette, Image};

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
    color_map: Index,
    reserved: u8,
    n_planes: u8,
    bytes_per_line: u16,
    palette_info: u16,
    h_screen_size: u16,
    v_screen_size: u16,
}

fn read_palette(reader: &mut dyn DataReader) -> Palette {
    let mut palette = Palette::new(16);

    for i in 0..16 {
        let r = reader.get_u8();
        let g = reader.get_u8();
        let b = reader.get_u8();

        palette.colors[i] = Color::new(r, g, b, if i == 0 { 0 } else { 255 });
    }

    palette
}

pub fn insert_palette_if_not_exists(
    palette_storage: &mut Arena<Palette>,
    palette: Palette,
) -> Index {
    for (index, p) in palette_storage.iter() {
        if p.equal(&palette) {
            return index;
        }
    }

    palette_storage.insert(palette)
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

    pub fn from(
        reader: &mut dyn DataReader,
        palette_storage: &mut Arena<Palette>,
    ) -> PcxHeader {
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
        let color_map = insert_palette_if_not_exists(palette_storage, read_palette(reader));
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
            v_screen_size,
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
                if i >= size || count == 0 {
                    break;
                }

                buf[i] = byte;
                count -= 1;
                i += 1;
            }
        }
    } else {
        while i < size {
            byte = reader.get_u8();
            buf[i] = byte;
            i += 1;
        }
    }
}

pub fn read_image_1(
    reader: &mut dyn DataReader,
    header: &PcxHeader,
    palette_storage: &mut Arena<Palette>,
) -> Image {
    let mut buf: Vec<u8> = Vec::new();
    buf.resize(header.bytes_per_line as usize, 0);
    let width = header.width();
    let mut pixels: Vec<u8> = vec![0u8; (header.width() * header.height()) as usize];

    for y in 0..header.height() {
        if reader.eof() {
            return Image::empty();
        }

        read_line(reader, &mut buf, header);

        let line_offset: usize = (width * y) as usize;
        let bpl = cmp::min((width + 7) / 8, header.bytes_per_line as i32);
        pixels[line_offset..((bpl as usize) + line_offset)]
            .clone_from_slice(&buf[..(bpl as usize)]);
    }

    // TODO: Reuse this static palette between calls
    let mut palette = Palette::new(2);
    palette.colors[0] = Color::new(0, 0, 0, 255);
    palette.colors[1] = Color::new(255, 255, 255, 255);

    Image::new(
        header.width() as usize,
        header.height() as usize,
        pixels,
        insert_palette_if_not_exists(palette_storage, palette),
    )
}

pub fn read_image_4(reader: &mut dyn DataReader, header: &PcxHeader) -> Image {
    let mut buf: Vec<u8> = Vec::new();
    buf.resize((header.bytes_per_line * 4) as usize, 0);
    let mut pixbuf: Vec<u8> = Vec::new();
    buf.resize(header.width() as usize, 0);

    let mut pixels: Vec<u8> = vec![0u8; (header.width() * header.height()) as usize];
    let width = header.width();

    for y in 0..header.height() {
        if reader.eof() {
            return Image::empty();
        }

        pixbuf.fill(0);

        read_line(reader, &mut buf, header);

        for i in 0..4 {
            let offset: usize = i * header.bytes_per_line as usize;
            for x in 0..(header.width() as usize) {
                if (buf[offset + (x / 8)] & (128 >> (x % 8))) != 0 {
                    pixbuf[x] += 1 << i;
                }
            }
        }

        let line_offset: usize = (width * y) as usize;

        pixels[line_offset..((header.width() as usize) + line_offset)]
            .clone_from_slice(&pixbuf[..(header.width() as usize)]);
    }

    Image::new(
        header.width() as usize,
        header.height() as usize,
        pixels,
        header.color_map,
    )
}

pub fn read_image_8(
    reader: &mut dyn DataReader,
    header: &PcxHeader,
    palette_storage: &mut Arena<Palette>
) -> Image {
    let mut buf: Vec<u8> = Vec::new();
    buf.resize(header.bytes_per_line as usize, 0);
    let mut pixels: Vec<u8> = vec![0u8; (header.width() * header.height()) as usize];
    let width = header.width();

    for y in 0..header.height() {
        if reader.eof() {
            return Image::empty();
        }

        read_line(reader, &mut buf, header);

        let line_offset: usize = (width * y) as usize;
        let bpl: usize = cmp::min(header.bytes_per_line as usize, width as usize);
        pixels[line_offset..(bpl + line_offset)].clone_from_slice(&buf[..bpl]);
    }

    let flag: u8 = reader.get_u8();
    let mut colors: Vec<Color> = Vec::with_capacity(256);

    if flag == 12 && (header.version == 5 || header.version == 2) {
        for i in 0..256 {
            let color = Color::new(
                reader.get_u8(),
                reader.get_u8(),
                reader.get_u8(),
                if i == 0 { 0 } else { 255 },
            );
            colors.push(color);
        }
    } else {
        warn!("error: unsupported pcx, palette not set");
    }

    Image::new(
        header.width() as usize,
        header.height() as usize,
        pixels,
        insert_palette_if_not_exists(palette_storage, Palette::from_colors(colors)),
    )
}

pub fn read_image_24(_: &mut dyn DataReader, _: &PcxHeader) -> Image {
    // TODO: Add 24bit support

    warn!("Unsupported 24bit pcx");

    Image::empty()
}

pub fn read_pcx(reader: &mut dyn DataReader, palette_storage: &mut Arena<Palette>) -> Result<Image, Error> {
    if reader.size() < 128 {
        return Result::Err(Error::new(
            ErrorKind::InvalidData,
            "Pcx data too small",
        ));
    }

    let header = PcxHeader::from(reader, palette_storage);

    if header.manufacturer != 10 || reader.eof() {
        return Result::Err(Error::new(
            ErrorKind::InvalidData,
            format!("Invalid pcx header: {}", header.manufacturer),
        ));
    }

    let img: Image;

    if header.bpp == 1 && header.n_planes == 1 {
        img = read_image_1(reader, &header, palette_storage);
    } else if header.bpp == 1 && header.n_planes == 4 {
        img = read_image_4(reader, &header);
    } else if header.bpp == 8 && header.n_planes == 1 {
        img = read_image_8(reader, &header, palette_storage);
    } else if header.bpp == 8 && header.n_planes == 3 {
        img = read_image_24(reader, &header);
    } else {
        img = Image::empty();
    }

    if img.pixels.len() > 0 {
        return Result::Ok(img);
    }

    Result::Err(Error::new(
        ErrorKind::InvalidData,
        "Failed decoding PCX pixels",
    ))
}
