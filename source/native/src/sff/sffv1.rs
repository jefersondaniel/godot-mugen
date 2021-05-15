use gdnative::api::file::File;
use crate::sff::data::{ DataError, BufferAccess, BufferReader, FileReader, DataReader };
use crate::sff::image::{ RawImage, RawColor, Palette };
use crate::sff::pcx::{ read_pcx };
use crate::sff::sff_common::{ SffData, SffPal };

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

    FileHeader { signature, verhi, verlo, verlo2, verlo3, num_groups, num_images, first_offset, subheader_size, is_shared, reserved, comments }
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

    SpriteHeader { offset_next_sprite, subfile_len, x, y, groupno, imageno, linked, is_shared, blank }
}

fn matrix_to_pal(reader: &mut dyn DataReader) -> Palette {
    let mut palette = Palette::new(0);
    for a in 0..256 {
        let r = reader.get_u8();
        let g = reader.get_u8();
        let b = reader.get_u8();
        palette.colors.push(RawColor::new(r, g, b, if a == 0 { 0 } else { 255 }));
    }
    palette
}

pub fn read_v1(filename: String, paldata: &mut Vec<SffPal>, sffdata: &mut Vec<SffData>) -> Result<(), DataError> {
    let file = File::new();
    let result = file.open(filename, File::READ);

    if let Err(detail) = result {
        return Result::Err(DataError::new(format!("Error opening sff file: {}", detail)));
    }

    let mut reader = FileReader::new(&file);
    let head = read_file_header(&mut reader);

    if head.signature != "ElecbyteSpr" {
        file.close();
        return Result::Err(DataError::new(format!("SffV1::read invalid signature: {}", head.signature)));
    }

    if head.verhi != 0 && head.verlo != 1 && head.verlo2 != 0 && head.verlo3 != 1 {
        file.close();
        return Result::Err(DataError::new(format!("SffV1::read invalid version: {}.{}.{}.{}", head.verhi, head.verlo, head.verlo2, head.verlo3)));
    }

    let mut actual_offset = head.first_offset;
    let mut pallete_ref: Vec<u8> = Vec::new();
    let mut counter: i32 = -1;
    let mut actual_palindex: i32 = 0;
    let mut shared_image: Vec<usize> = Vec::new();
    let mut ind_image: Vec<usize> = Vec::new();

    while !file.eof_reached() {
        counter += 1;
        let mut sffitem = SffData {
            image: RawImage::empty(),
            groupno: 0,
            imageno: 0,
            x: 0,
            y: 0,
            palindex: 0,
            linked: 0,
        };

        if counter >= head.num_images as i32 {
            break;
        }

        let spr = read_sprite_header(&mut reader);
        let array_size = spr.offset_next_sprite - actual_offset - 32;

        if array_size > 0 {
            let mut tmp_arr = reader.get_buffer(array_size as usize) ;

            if head.is_shared && spr.is_shared {
                shared_image.push(counter as usize);
                for _ in 0..768 {
                    tmp_arr.push(0u8);
                }
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
                    for k in 0..paldata.len() {
                        if sffpal.pal.equal(&paldata[k].pal) {
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
                    return Result::Err(DataError::new(format!("Pcx Error: {}. Buffer size: {}", error, tmp_arr.len())));
                }
            }
            tmp_arr.clear();
        } else {
            // linked image
            sffitem.image = sffdata[spr.linked as usize].image.clone();
            sffitem.palindex = sffdata[spr.linked as usize].palindex;
            if head.is_shared && spr.is_shared {
                shared_image.push(counter as usize);
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

        sffdata.push(sffitem);
        actual_offset = spr.offset_next_sprite;
    }

    if head.is_shared {
        let mut force_pal = Palette::new(0);
        let mut have0 = false;
        for k in 0..ind_image.len() {
            if sffdata[ind_image[k]].groupno == 0 {
                have0 = true;
                force_pal = sffdata[ind_image[k]].image.color_table.clone();
                break;
            }
        }
        if !have0 {
            let mut have90 = false;
            for k in 0..ind_image.len() {
                let alfa = ind_image[k];
                if sffdata[alfa].groupno == 9000 && sffdata[alfa].imageno == 0 {
                    have90 = true;
                    force_pal = sffdata[ind_image[k]].image.color_table.clone();
                    break;
                }
            }
            if have90 == false {
                force_pal = sffdata[ind_image[0]].image.color_table.clone();
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
                for w in 0..sffdata.len() {
                    if sffdata[w].palindex == 0 {
                        sffdata[w].palindex = k as i32;
                    } else if sffdata[w].palindex == k as i32 {
                        sffdata[w].palindex = 0;
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

        for k in 0..shared_image.len() {
            sffdata[shared_image[k]].image.color_table = force_pal.clone();
            sffdata[shared_image[k]].palindex = 0;
        }
    }

    file.close();

    Result::Ok(())
}
