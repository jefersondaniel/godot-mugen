use crate::sff::data::{BufferAccess, BufferReader, DataError, DataReader, FileReader};
use crate::sff::image::{Palette, RawColor, RawImage};
use crate::sff::pcx::read_pcx;
use crate::sff::sff_common::{SffData, SffPal, SffMetadata, SffReference};
use gdnative::object::Ref;
use gdnative::api::File;
use gdnative::prelude::Unique;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

#[allow(dead_code)]
struct FileHeader {
    signature: String, // [u8; 12],
    verhi: u8,
    verlo: u8,
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

struct FileHandler {
    file: Rc<Ref<File, Unique>>,
    head: FileHeader
}

fn read_file_header(reader: &mut dyn DataReader) -> FileHeader {
    let signature: String = reader.get_text(12);
    let verhi: u8 = reader.get_u8();
    let verlo: u8 = reader.get_u8();
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
        verlo,
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

fn matrix_to_pal(reader: &mut dyn DataReader) -> Rc<Palette> {
    let mut colors: Vec<RawColor> = Vec::new();
    for a in 0..256 {
        let r = reader.get_u8();
        let g = reader.get_u8();
        let b = reader.get_u8();
        colors.push(RawColor::new(r, g, b, if a == 0 { 0 } else { 255 }));
    }
    Rc::new(Palette::from_colors(colors))
}

fn open(filename: &str) -> Result<FileHandler, DataError> {
    let file = Rc::new(File::new());
    let result = file.open(filename, File::READ);

    if let Err(detail) = result {
        return Result::Err(DataError::new(format!(
            "error opening file: {}",
            detail
        )));
    }

    let mut reader = FileReader::new(&file);
    let head = read_file_header(&mut reader);

    if head.signature != "ElecbyteSpr" {
        file.close();
        return Result::Err(DataError::new(format!(
            "invalid signature: {}",
            head.signature
        )));
    }

    if head.verhi != 0 && head.verlo != 1 && head.verlo2 != 0 && head.verlo3 != 1 {
        file.close();
        return Result::Err(DataError::new(format!(
            "invalid version: {}.{}.{}.{}",
            head.verhi, head.verlo, head.verlo2, head.verlo3
        )));
    }

    Result::Ok(FileHandler {
        file,
        head
    })
}

pub fn read_metadata(filename: &str) -> Result<SffMetadata, DataError> {
    let open_result = open(filename);

    if let Err(error) = open_result {
        return Result::Err(error);
    }

    let handler = open_result.expect("Invalid open result");
    let file = handler.file;
    let head = handler.head;
    let mut reader = FileReader::new(&file);
    let mut counter = 0;
    let mut images: Vec<SffReference> = Vec::new();
    let mut actual_offset = head.first_offset;

    while !file.eof_reached() {
        counter += 1;

        if counter >= head.num_images as i32 {
            break;
        }

        file.seek(actual_offset as i64);

        let spr = read_sprite_header(&mut reader);

        images.push(SffReference {
            groupno: spr.groupno,
            imageno: spr.imageno
        });

        actual_offset = spr.offset_next_sprite;
    }

    file.close();

    Result::Ok(SffMetadata { major_version: 1, images })
}

pub fn read_images(filename: &str, groups: &[i16]) -> Result<Vec<SffData>, DataError> {
    let open_result = open(filename);

    if let Err(error) = open_result {
        return Result::Err(error);
    }

    let handler = open_result.expect("Invalid open result");
    let file = handler.file;
    let head = handler.head;
    let mut actual_offset = head.first_offset;
    let mut counter: i32 = -1;
    let mut reader = FileReader::new(&file);
    let mut requested_indexes: Vec<i32> = Vec::new();

    while !file.eof_reached() {
        counter += 1;

        if counter >= head.num_images as i32 {
            break;
        }

        file.seek(actual_offset as i64);

        let spr = read_sprite_header(&mut reader);
        let array_size = spr.offset_next_sprite - actual_offset - 32;

        if groups.contains(&spr.groupno) {
            requested_indexes.push(counter);

            if array_size == 0 {
                requested_indexes.push(spr.linked as i32);
            }
        }

        actual_offset = spr.offset_next_sprite;
    }

    let mut pallete_ref: Vec<u8> = Vec::new();
    let mut actual_palindex: i32 = 0;
    let mut shared_image: Vec<usize> = Vec::new();
    let mut ind_image: Vec<usize> = Vec::new();
    let mut sffdata: HashMap<i32, SffData> = HashMap::new();
    let mut paldata: Vec<SffPal> = Vec::new();

    file.seek(head.first_offset as i64);
    counter = -1;
    actual_offset = head.first_offset;

    while !file.eof_reached() {
        counter += 1;

        if counter >= head.num_images as i32 {
            break;
        }

        if !groups.is_empty() && !requested_indexes.contains(&counter) {
            continue;
        }

        file.seek(actual_offset as i64);

        let mut sffitem = SffData {
            image: Rc::new(RefCell::new(RawImage::empty())),
            groupno: 0,
            imageno: 0,
            x: 0,
            y: 0,
            palindex: 0,
            linked: 0,
        };

        let spr = read_sprite_header(&mut reader);
        let array_size = spr.offset_next_sprite - actual_offset - 32;

        if array_size > 0 {
            let mut tmp_arr = reader.get_buffer(array_size as usize);

            if head.is_shared && spr.is_shared {
                shared_image.push(counter as usize);
                tmp_arr.append(&mut vec![0u8; 768]);
            }

            if !head.is_shared && spr.is_shared {
                tmp_arr.extend(pallete_ref.to_vec());
            }

            if !spr.is_shared {
                ind_image.push(counter as usize);
                actual_palindex = paldata.len() as i32;
                pallete_ref = tmp_arr.clone();
                pallete_ref = pallete_ref.right(768);
                tmp_arr.extend(pallete_ref.to_vec());
                let mut palete_ref_reader = BufferReader::new(&pallete_ref);
                let sffpal = SffPal {
                    pal: matrix_to_pal(&mut palete_ref_reader),
                    groupno: paldata.len() as i32 + 1,
                    itemno: 1,
                    is_used: true,
                    usedby: counter,
                    reserved: 0,
                };
                {
                    let mut checked = false;
                    for (k, item) in paldata.iter().enumerate() {
                        if sffpal.pal.equal(&item.pal) {
                            checked = true;
                            actual_palindex = k as i32;
                            break;
                        }
                    }
                    if !checked {
                        paldata.push(sffpal);
                    }
                }
            }
            sffitem.palindex = actual_palindex;
            {
                let mut tmp_arr_reader = BufferReader::new(&tmp_arr);
                let result = read_pcx(&mut tmp_arr_reader);
                if let Ok(image) = result {
                    sffitem.image = image;
                } else if let Err(error) = result {
                    return Result::Err(DataError::new(format!(
                        "pcx: {}. buffer size: {}",
                        error,
                        tmp_arr.len()
                    )));
                }
            }
            tmp_arr.clear();
        } else {
            // linked image
            match sffdata.get(&(spr.linked as i32)) {
                Some(linked) => {
                    sffitem.image = Rc::clone(&linked.image);
                    sffitem.palindex = linked.palindex;
                    if head.is_shared && spr.is_shared {
                        shared_image.push(counter as usize);
                    }
                },
                None => {
                    return Result::Err(DataError::new(format!(
                        "invalid linked image: {},{}",
                        spr.groupno,
                        spr.imageno
                    )));
                }
            }
        }

        sffitem.groupno = spr.groupno as i32;
        sffitem.imageno = spr.imageno as i32;
        sffitem.x = spr.x as i32;
        sffitem.y = spr.y as i32;
        sffitem.linked = -1;

        if head.is_shared && spr.is_shared {
            sffitem.palindex = 0;
        }

        sffdata.insert(counter, sffitem);
        actual_offset = spr.offset_next_sprite;
    }

    if head.is_shared {
        let mut force_pal = Rc::new(Palette::new(0));
        let mut have0 = false;
        for other in ind_image.iter() {
            match sffdata.get(&(*other as i32)) {
                Some(linked) => {
                    if linked.groupno == 0 {
                        have0 = true;
                        force_pal = Rc::clone(&linked.image.borrow().color_table);
                        break;
                    }
                },
                None => {
                    return Result::Err(DataError::new(format!(
                        "invalid shared image: other = {}",
                        other
                    )));
                }
            }
        }
        if !have0 {
            let mut have90 = false;
            for other in ind_image.iter() {
                match sffdata.get(&(*other as i32)) {
                    Some(linked) => {
                        if linked.groupno == 9000 && linked.imageno == 0 {
                            have90 = true;
                            force_pal = Rc::clone(&linked.image.borrow().color_table);
                            break;
                        }
                    },
                    None => {
                        return Result::Err(DataError::new(format!(
                            "invalid shared image: other = {}",
                            other
                        )));
                    }
                }
            }
            if !have90 {
                match sffdata.get(&(ind_image[0] as i32)) {
                    Some(linked) => {
                        force_pal = Rc::clone(&linked.image.borrow().color_table);
                    },
                    None => {
                        return Result::Err(DataError::new("invalid shared image: k = 0".to_string()));
                    }
                }
            }
        }

        {
            let mut k = 0;

            loop {
                if force_pal.equal(&paldata[k].pal) {
                    break;
                }

                if k >= paldata.len() - 1 {
                    break;
                }

                k += 1;
            }

            if k > 0 {
                for (_, item) in sffdata.iter_mut() {
                    if item.palindex == 0 {
                        item.palindex = k as i32;
                    } else if item.palindex == k as i32 {
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
                    shared.image.borrow_mut().color_table = Rc::clone(&force_pal);
                    shared.palindex = 0;
                },
                None => {
                    return Result::Err(DataError::new(format!(
                        "invalid shared image: other = {}",
                        other
                    )));
                }
            }
        }
    }

    file.close();

    let mut result: Vec<SffData> = Vec::new();

    for value in sffdata.values() {
        result.push(value.clone());
    }

    Result::Ok(result)
}

pub fn load_pal_format_pal(filename: &str) -> Result<Rc<Palette>, DataError> {
    let mut pal: Palette = Palette::new(0);
    let file = File::new();
    let result = file.open(filename, File::READ);

    if let Err(details) = result {
        file.close();
        return Result::Err(DataError {
            message: format!("Error opening palette {}", details),
        });
    }

    if file.get_line().to_uppercase().to_string() != "JASC-PAL" {
        file.close();
        return Result::Err(DataError {
            message: "Invalid pallete header".to_string(),
        });
    }

    file.get_line(); //0100
    file.get_line(); //256 (color palette)
    let mut counter = -1;

    while !file.eof_reached() {
        counter += 1;
        let line = file.get_line().to_string();
        let strcolor: Vec<&str> = line.split(' ').collect::<Vec<&str>>();
        if strcolor.len() < 3 {
            continue;
        }
        let r: Result<u8, u8> = strcolor[0].parse().or(Ok(0));
        let g: Result<u8, u8> = strcolor[1].parse().or(Ok(0));
        let b: Result<u8, u8> = strcolor[2].parse().or(Ok(0));
        pal.colors.push(RawColor::new(
            r.unwrap(),
            g.unwrap(),
            b.unwrap(),
            if 0 == counter { 0 } else { 255 },
        ));
    }

    if pal.colors.is_empty() {
        return Result::Err(DataError {
            message: "invalid palette file, no colors".to_string(),
        });
    }

    file.close();

    Result::Ok(Rc::new(pal))
}

pub fn load_pal_format_act(filename: &str) -> Result<Rc<Palette>, DataError> {
    let mut pal: Palette = Palette::new(0);
    let file = File::new();
    let result = file.open(filename, File::READ);

    if let Err(details) = result {
        file.close();
        return Result::Err(DataError {
            message: format!("Error opening palette {}", details),
        });
    }

    let mut reader = FileReader::new(&file);
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

    Result::Ok(Rc::new(pal))
}

pub fn read_palette(palette_path: &str) -> Result<Rc<Palette>, DataError> {
    let act_extension = ".act";
    let palette_result;

    if palette_path.to_lowercase().ends_with(act_extension) {
        palette_result = load_pal_format_act(palette_path);
    } else {
        palette_result = load_pal_format_pal(palette_path);
    }

    palette_result
}
