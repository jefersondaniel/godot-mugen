use std::collections::HashMap;
use std::io::{ErrorKind,Error};
use std::sync::Arc;

use thunderdome::{Arena, Index};

use crate::io::reader::{BufferAccess, BufferReader, DataReader};
use crate::types::Color;
use super::image::{Palette, Image};
use super::pcx::read_pcx;
use super::sff_common::{SffData, SffPal, SffMetadata};

#[allow(dead_code)]
struct FileHeader {
    signature: String, // [u8; 12],
    verhi: u8,
    verlo1: u8,
    verlo2: u8,
    verlo3: u8,
    num_groups: u32,
    num_images: u32,
    first_offset: u32,
    subheader_size: u32,
    is_shared: bool,
    reserved: Vec<u8>, // [u8; 3],
    comments: Vec<u8>, // [u8; 476],
}

#[allow(dead_code)]
struct SpriteHeader {
    offset_next_sprite: u32,
    subfile_len: u32,
    x: i16,
    y: i16,
    groupno: i16,
    imageno: i16,
    linked: i16,
    is_shared: bool,
    blank: Vec<u8>,
}

#[derive(PartialEq)]
pub enum PaletteFileFormat {
    Act,
    Pal
}

fn read_file_header(reader: &mut dyn DataReader) -> FileHeader {
    let signature: String = reader.get_text(12);
    let verhi: u8 = reader.get_u8();
    let verlo1: u8 = reader.get_u8();
    let verlo2: u8 = reader.get_u8();
    let verlo3: u8 = reader.get_u8();
    let num_groups: u32 = reader.get_u32();
    let num_images: u32 = reader.get_u32();
    let first_offset: u32 = reader.get_u32();
    let subheader_size: u32 = reader.get_u32();
    let is_shared: bool = reader.get_bool();
    let reserved: Vec<u8> = reader.get_buffer(3);
    let comments: Vec<u8> = reader.get_buffer(476);

    FileHeader {
        signature,
        verhi,
        verlo1,
        verlo2,
        verlo3,
        num_groups,
        num_images,
        first_offset,
        subheader_size,
        is_shared,
        reserved,
        comments,
    }
}

fn read_sprite_header(reader: &mut dyn DataReader) -> SpriteHeader {
    let offset_next_sprite: u32 = reader.get_u32();
    let subfile_len: u32 = reader.get_u32();
    let x: i16 = reader.get_i16();
    let y: i16 = reader.get_i16();
    let groupno: i16 = reader.get_i16();
    let imageno: i16 = reader.get_i16();
    let linked: i16 = reader.get_i16();
    let is_shared: bool = reader.get_bool();
    let blank: Vec<u8> = reader.get_buffer(13);

    SpriteHeader {
        offset_next_sprite,
        subfile_len,
        x,
        y,
        groupno,
        imageno,
        linked,
        is_shared,
        blank,
    }
}

fn matrix_to_pal(reader: &mut dyn DataReader) -> Palette {
    let mut colors: Vec<Color> = Vec::new();
    for a in 0..256 {
        let r = reader.get_u8();
        let g = reader.get_u8();
        let b = reader.get_u8();
        colors.push(Color::new(r, g, b, if a == 0 { 0 } else { 255 }));
    }
    Palette::from_colors(colors)
}

fn open(reader: &mut dyn DataReader) -> Result<FileHeader, Error> {
    let head = read_file_header(reader);

    if head.signature != "ElecbyteSpr" {
        return Result::Err(Error::new(
            ErrorKind::InvalidData,
            format!(
                "Invalid signature: {}",
                head.signature
            )
        ));
    }

    if head.verhi != 0 && head.verlo1 != 1 && head.verlo2 != 0 && head.verlo3 != 1 {
        return Result::Err(Error::new(
            ErrorKind::InvalidData,
            format!(
                "Invalid version: {}.{}.{}.{}",
                head.verhi, head.verlo1, head.verlo2, head.verlo3
            ))
        );
    }

    Result::Ok(head)
}

pub fn read_metadata(reader: &mut dyn DataReader) -> Result<SffMetadata, Error> {
    let head = open(reader)?;

    Result::Ok(SffMetadata {
        verlo3: head.verlo3,
        verlo2: head.verlo2,
        verlo1: head.verlo1,
        verhi: head.verhi,
    })
}

pub fn read_images(
    reader: &mut dyn DataReader,
    groups: &[i16],
    image_storage: &mut Arena<Image>,
    palette_storage: &mut Arena<Palette>,
) -> Result<Vec<SffData>, Error> {
    let head = open(reader)?;
    let mut actual_offset = head.first_offset;
    let mut counter: i32 = -1;
    let mut requested_indexes: Vec<i32> = Vec::new();

    while !reader.eof() {
        counter += 1;

        if counter >= head.num_images as i32 {
            break;
        }

        reader.seek(actual_offset as usize);

        let spr = read_sprite_header(reader);
        let array_size = spr.offset_next_sprite - actual_offset - 32;

        if groups.contains(&spr.groupno) {
            requested_indexes.push(counter);

            if array_size == 0 {
                requested_indexes.push(spr.linked as i32);
            }
        }

        actual_offset = spr.offset_next_sprite;
    }

    let mut palette_ref: Vec<u8> = Vec::new();
    let mut actual_palindex: i16 = 0;
    let mut shared_image: Vec<usize> = Vec::new();
    let mut ind_image: Vec<usize> = Vec::new();
    let mut sffdata: HashMap<i32, SffData> = HashMap::new();
    let mut paldata: Vec<SffPal> = Vec::new();

    reader.seek(head.first_offset as usize);
    counter = -1;
    actual_offset = head.first_offset;

    while !reader.eof() {
        counter += 1;

        if counter >= head.num_images as i32 {
            break;
        }

        if !groups.is_empty() && !requested_indexes.contains(&counter) {
            continue;
        }

        reader.seek(actual_offset as usize);

        let mut sffitem = SffData {
            image: Index::DANGLING,
            groupno: 0,
            imageno: 0,
            x: 0,
            y: 0,
            palindex: 0,
            linked: 0,
        };

        let spr = read_sprite_header(reader);
        let array_size = spr.offset_next_sprite - actual_offset - 32;

        if array_size > 0 {
            let mut tmp_arr = reader.get_buffer(array_size as usize);

            if head.is_shared && spr.is_shared {
                shared_image.push(counter as usize);
                tmp_arr.append(&mut vec![0u8; 768]);
            }

            if !head.is_shared && spr.is_shared {
                tmp_arr.extend(palette_ref.to_vec());
            }

            if !spr.is_shared {
                ind_image.push(counter as usize);
                actual_palindex = paldata.len() as i16;
                palette_ref = tmp_arr.clone();
                palette_ref = palette_ref.right(768);
                tmp_arr.extend(palette_ref.to_vec());
                let mut palete_ref_reader = BufferReader::new(palette_ref.clone());
                let temporary_pal = matrix_to_pal(&mut palete_ref_reader);
                {
                    let mut checked = false;
                    for (k, item) in paldata.iter().enumerate() {
                        let item_pal = palette_storage.get(item.pal);
                        if let Some(item_pal) = item_pal {
                            if item_pal.equal(&temporary_pal) {
                                checked = true;
                                actual_palindex = k as i16;
                                break;
                            }
                        }
                    }
                    if !checked {
                        let sffpal = SffPal {
                            pal: palette_storage.insert(temporary_pal),
                            groupno: paldata.len() as i32 + 1,
                            itemno: 1,
                            is_used: true,
                            usedby: counter,
                            reserved: 0,
                        };
                        paldata.push(sffpal);
                    }
                }
            }
            sffitem.palindex = actual_palindex;
            {
                let mut tmp_arr_reader = BufferReader::new(tmp_arr.clone());
                sffitem.image = image_storage.insert(read_pcx(&mut tmp_arr_reader, palette_storage)?);
            }
            tmp_arr.clear();
        } else {
            // linked image
            match sffdata.get(&(spr.linked as i32)) {
                Some(linked) => {
                    sffitem.image = linked.image;
                    sffitem.palindex = linked.palindex;
                    if head.is_shared && spr.is_shared {
                        shared_image.push(counter as usize);
                    }
                },
                None => {
                    return Result::Err(Error::new(
                        ErrorKind::InvalidData,
                        format!(
                            "Invalid linked image: {},{}",
                            spr.groupno,
                            spr.imageno
                        )
                    ));
                }
            }
        }

        sffitem.groupno = spr.groupno;
        sffitem.imageno = spr.imageno;
        sffitem.x = spr.x;
        sffitem.y = spr.y;
        sffitem.linked = -1;

        if head.is_shared && spr.is_shared {
            sffitem.palindex = 0;
        }

        sffdata.insert(counter, sffitem);
        actual_offset = spr.offset_next_sprite;
    }

    if head.is_shared {
        let mut force_pal = Index::DANGLING;
        let mut have0 = false;
        for other in ind_image.iter() {
            match sffdata.get(&(*other as i32)) {
                Some(linked) => {
                    if linked.groupno == 0 {
                        let linked_image_option = image_storage.get(linked.image);
                        if let Some(linked_image) = linked_image_option {
                            have0 = true;
                            force_pal = linked_image.palette;
                        }
                        break;
                    }
                },
                None => {
                    return Result::Err(Error::new(
                        ErrorKind::InvalidData,
                        format!(
                            "invalid shared image: other = {}",
                            other
                        )
                    ));
                }
            }
        }
        if !have0 {
            let mut have90 = false;
            for other in ind_image.iter() {
                match sffdata.get(&(*other as i32)) {
                    Some(linked) => {
                        if linked.groupno == 9000 && linked.imageno == 0 {
                            let linked_image_option = image_storage.get(linked.image);
                            if let Some(linked_image) = linked_image_option {
                                have90 = true;
                                force_pal = linked_image.palette;
                            }
                            break;
                        }
                    },
                    None => {
                        return Result::Err(Error::new(
                            ErrorKind::InvalidData,
                            format!(
                                "Invalid shared image. Other = {}",
                                other
                            )
                        ));
                    }
                }
            }
            if !have90 {
                match sffdata.get(&(ind_image[0] as i32)) {
                    Some(linked) => {
                        let linked_image_option = image_storage.get(linked.image);
                        if let Some(linked_image) = linked_image_option {
                            force_pal = linked_image.palette;
                        }
                    },
                    None => {
                        return Result::Err(
                            Error::new(
                                ErrorKind::InvalidData,
                                "Invalid shared image: k = 0"
                            )
                        );
                    }
                }
            }
        }

        {
            let mut k = 0;

            loop {
                if let (Some(force_pal_palette), Some(pal_palette)) = (palette_storage.get(force_pal), palette_storage.get(paldata[k].pal)) {
                    if force_pal_palette.equal(pal_palette) {
                        break;
                    }
                }

                if k >= paldata.len() - 1 {
                    break;
                }

                k += 1;
            }

            if k > 0 {
                for (_, item) in sffdata.iter_mut() {
                    if item.palindex == 0 {
                        item.palindex = k as i16;
                    } else if item.palindex == k as i16 {
                        item.palindex = 0;
                    }
                }
                paldata[0].groupno = paldata[k].groupno;
                paldata[0].itemno = paldata[k].itemno;
                paldata[k].groupno = 1;
                paldata[k].itemno = 1;

                let aux = paldata[0].clone();
                paldata[0] = paldata[k].clone();
                paldata[k] = aux;
            }
        }

        for other in shared_image.iter() {
            match sffdata.get_mut(&(*other as i32)) {
                Some(shared) => {
                    let shared_image_option = image_storage.get_mut(shared.image);
                    if let Some(shared_image) = shared_image_option {
                        shared_image.palette = force_pal;
                        shared.palindex = 0;
                    }
                },
                None => {
                    return Result::Err(
                        Error::new(
                            ErrorKind::InvalidData,
                            format!("invalid shared image: other = {}", other)
                        )
                    );
                }
            }
        }
    }

    Result::Ok(sffdata.into_values().collect())
}

pub fn load_pal_format_pal(reader: &mut dyn DataReader) -> Result<Arc<Palette>, Error> {
    let mut pal: Palette = Palette::new(0);

    if reader.get_line().to_uppercase() != "JASC-PAL" {
        return Result::Err(Error::new(
            ErrorKind::InvalidData,
            "Invalid pallete header",
        ));
    }

    reader.get_line(); //0100
    reader.get_line(); //256 (color palette)
    let mut counter = -1;

    while !reader.eof() {
        counter += 1;
        let line = reader.get_line().to_string();
        let strcolor: Vec<&str> = line.split(' ').collect::<Vec<&str>>();
        if strcolor.len() < 3 {
            continue;
        }
        let r: Result<u8, u8> = strcolor[0].parse().or(Ok(0));
        let g: Result<u8, u8> = strcolor[1].parse().or(Ok(0));
        let b: Result<u8, u8> = strcolor[2].parse().or(Ok(0));
        pal.colors.push(Color::new(
            r.unwrap(),
            g.unwrap(),
            b.unwrap(),
            if 0 == counter { 0 } else { 255 },
        ));
    }

    if pal.colors.is_empty() {
        return Result::Err(Error::new(
            ErrorKind::InvalidData,
            "Invalid palette file, no colors"
        ));
    }

    Result::Ok(Arc::new(pal))
}

pub fn load_pal_format_act(reader: &mut dyn DataReader) -> Result<Arc<Palette>, Error> {
    let mut pal: Palette = Palette::new(0);
    let mut reversed: Vec<Color> = Vec::new();

    for a in 0..256 {
        let r = reader.get_u8();
        let g = reader.get_u8();
        let b = reader.get_u8();
        reversed.push(Color::new(r, g, b, if a == 255 { 0 } else { 255 }));
    }

    let mut i: i64 = reversed.len() as i64 - 1;

    while i >= 0 {
        pal.colors.push(reversed[i as usize]);
        i -= 1;
    }


    Result::Ok(Arc::new(pal))
}

pub fn detect_palette_format(name: &str) -> Result<PaletteFileFormat, Error> {
    let act_extension = ".act";
    let pal_extension = ".pal";

    if name.to_lowercase().ends_with(act_extension) {
        return Result::Ok(PaletteFileFormat::Act);
    }

    if name.to_lowercase().ends_with(pal_extension) {
        return Result::Ok(PaletteFileFormat::Pal);
    }

    Result::Err(Error::new(
        ErrorKind::InvalidData,
        format!("Invalid palette file format: {}", name)
    ))
}

pub fn read_palette(reader: &mut dyn DataReader, format: PaletteFileFormat) -> Result<Arc<Palette>, Error> {
    let palette_result;

    if format == PaletteFileFormat::Act {
        palette_result = load_pal_format_act(reader);
    } else {
        palette_result = load_pal_format_pal(reader);
    }

    palette_result
}
