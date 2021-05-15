use gdnative::prelude::*;
use gdnative::api::file::File;
use crate::sff::data::{ FileReader, DataReader, DataError };
use crate::sff::image::{ RawImage, Palette, RawColor };

#[derive(Clone)]
pub struct SffPal {
    pub pal: Palette,
    pub itemno: i32,
    pub groupno: i32,
    pub is_used: bool,
    pub usedby: i32,
    pub reserved: i32,
}

#[derive(Clone)]
pub struct SffData {
    pub image: RawImage,
    pub groupno: i32,
    pub imageno: i32,
    pub x: i32,
    pub y: i32,
    pub palindex: i32,
    pub linked: i32,
}

pub fn load_pal_format_pal(filename: String) -> Result<Palette, DataError> {
    let mut pal: Palette = Palette::new(0);
    let file = File::new();
    let result = file.open(filename, File::READ);

    if let Err(details) = result {
        file.close();
        return Result::Err(DataError { message: format!("Error opening palette {}", details) });
    }

    if file.get_line().to_uppercase().to_string() != "JASC-PAL" {
        file.close();
        return Result::Err(DataError { message: format!("Invalid pallete header") });
    }

    file.get_line(); //0100
    file.get_line(); //256 (color palette)
    let mut counter = -1;

    while !file.eof_reached() {
        counter += 1;
        let line = file.get_line().to_string();
        let strcolor: Vec<&str> = line
            .split(" ")
            .collect::<Vec<&str>>();
        if strcolor.len() < 3 {
            godot_print!("warning: invalid palette line");
            continue;
        }
        let r: Result<u8, u8> = strcolor[0].parse().or_else(|_| Ok(0));
        let g: Result<u8, u8> = strcolor[1].parse().or_else(|_| Ok(0));
        let b: Result<u8, u8> = strcolor[2].parse().or_else(|_| Ok(0));
        pal.colors.push(RawColor::new(
            r.unwrap(),
            g.unwrap(),
            b.unwrap(),
            if 0 == counter { 0 } else { 255 }
        ));
    }

    if pal.colors.len() == 0 {
        godot_print!("warning: invalid palette file, no colors");
    }

    file.close();

    return Result::Ok(pal);
}

pub fn load_pal_format_act(filename: String) -> Result<Palette, DataError> {
    let mut pal: Palette = Palette::new(0);
    let file = File::new();
    let result = file.open(filename, File::READ);

    if let Err(details) = result {
        file.close();
        return Result::Err(
            DataError { message: format!("Error opening palette {}", details) }
        );
    }

    let mut reader  = FileReader::new(&file);
    let mut reversed: Vec<RawColor> = Vec::new();

    for a in 0..256 {
        let r = reader.get_u8();
        let g = reader.get_u8();
        let b = reader.get_u8();
        reversed.push(RawColor::new(r, g, b, if a == 255 { 0 } else { 255 }));
    }

    let mut i: i64 = reversed.len() as i64 - 1;

    while i >= 0 {
        pal.colors.push(reversed[i as usize]);
        i -= 1;
    }

    file.close();

    return Result::Ok(pal);
}
