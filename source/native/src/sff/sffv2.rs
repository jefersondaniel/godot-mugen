use std::rc::{ Rc };
use std::cell::RefCell;
use gdnative::api::file::File;
use crate::sff::data::{ DataError, BufferReader, FileReader, DataReader };
use crate::sff::image::{ RawImage, RawColor, Palette };
use crate::sff::sff_common::{ SffData, SffPal };
use crate::sff::lz5::decode_lz5;
use crate::sff::rle5::{ decode_rle5, decode_rle8 };

#[allow(dead_code)]
struct FileHeader {
    signature: String,
    verlo3: u8,
    verlo2: u8,
    verlo1: u8,
    verhi: u8,
    reserved1: Vec<u8>, // [u8, 4]
    reserved2: Vec<u8>, // [u8, 4]
    compatverlo3: u8,
    compatverlo2: u8,
    compatverlo1: u8,
    compatverhi: u8,
    reserved3: Vec<u8>, // [u8; 4]
    reserved4: Vec<u8>, // [u8; 4]
    first_sprnode_offset: u32,
    total_frames: u32,
    first_palnode_offset: u32,
    total_palettes: u32,
    ldata_offset: u32,
    ldata_length: u32,
    tdata_offset: u32,
    tdata_length: u32,
    reserved5: Vec<u8>, // [u8; 4]
    reserved6: Vec<u8>, // [u8; 4]
    unused: Vec<u8>, // [u8; 436
}

impl FileHeader {
    fn read(reader: &mut dyn DataReader) -> FileHeader {
        FileHeader {
            signature: reader.get_text(12),
            verlo3: reader.get_u8(),
            verlo2: reader.get_u8(),
            verlo1: reader.get_u8(),
            verhi: reader.get_u8(),
            reserved1: reader.get_buffer(4),
            reserved2: reader.get_buffer(4),
            compatverlo3: reader.get_u8(),
            compatverlo2: reader.get_u8(),
            compatverlo1: reader.get_u8(),
            compatverhi: reader.get_u8(),
            reserved3: reader.get_buffer(4),
            reserved4: reader.get_buffer(4),
            first_sprnode_offset: reader.get_u32(),
            total_frames: reader.get_u32(),
            first_palnode_offset: reader.get_u32(),
            total_palettes: reader.get_u32(),
            ldata_offset: reader.get_u32(),
            ldata_length: reader.get_u32(),
            tdata_offset: reader.get_u32(),
            tdata_length: reader.get_u32(),
            reserved5: reader.get_buffer(4),
            reserved6: reader.get_buffer(4),
            unused: reader.get_buffer(436),
        }
    }
}

struct SpriteHeader {
    groupno: i16,
    imageno: i16,
    w: i16,
    h: i16,
    x: i16,
    y: i16,
    linked: i16,
    fmt: u8,
    colordepth: u8,
    offset: u32,
    len: u32,
    palindex: i16,
    flags: i16,
}

impl SpriteHeader {
    fn read(reader: &mut dyn DataReader) -> SpriteHeader {
        SpriteHeader {
            groupno: reader.get_i16(),
            imageno: reader.get_i16(),
            w: reader.get_i16(),
            h: reader.get_i16(),
            x: reader.get_i16(),
            y: reader.get_i16(),
            linked: reader.get_i16(),
            fmt: reader.get_u8(),
            colordepth: reader.get_u8(),
            offset: reader.get_u32(),
            len: reader.get_u32(),
            palindex: reader.get_i16(),
            flags: reader.get_i16(),
        }
    }
}

struct PaletteHeader {
    groupno: i16,
    itemno: i16,
    numcols: i16,
    linked: i16,
    offset: u32,
    len: u32,
}

impl PaletteHeader {
    fn read(reader: &mut dyn DataReader) -> PaletteHeader {
        PaletteHeader {
            groupno: reader.get_i16(),
            itemno: reader.get_i16(),
            numcols: reader.get_i16(),
            linked: reader.get_i16(),
            offset: reader.get_u32(),
            len: reader.get_u32(),
        }
    }
}

fn matrix_to_pal(reader: &mut dyn DataReader, size: usize) -> Rc<Palette> {
    let mut colors: Vec<RawColor> = Vec::new();
    for i in 0..size {
        let r = reader.get_u8();
        let g = reader.get_u8();
        let b = reader.get_u8();
        reader.get_u8();
        colors.push(RawColor::new(r, g, b, if i == 0 { 0 } else { 255 }));
    }
    Rc::new(Palette::from_colors(colors))
}

pub fn read_v2(filename: String, paldata: &mut Vec<SffPal>, sffdata: &mut Vec<SffData>) -> Result<(), DataError> {
    let file = File::new();
    let result = file.open(filename, File::READ);

    if let Err(detail) = result {
        return Result::Err(DataError::new(format!("Error opening sff file: {}", detail)));
    }

    let mut reader = FileReader::new(&file);
    let head = FileHeader::read(&mut reader);

    if head.signature != "ElecbyteSpr" {
        file.close();
        return Result::Err(DataError::new(format!("SffV2::read invalid signature: {}", head.signature)));
    }

    if head.verhi != 2 {
        file.close();
        return Result::Err(DataError::new(format!("SffV2::read invalid version: {}.{}.{}.{}", head.verhi, head.verlo1, head.verlo2, head.verlo3)));
    }

    let mut sprnode: Vec<SpriteHeader> = Vec::new();
    let mut palnode: Vec<PaletteHeader> = Vec::new();

    file.seek(head.first_palnode_offset as i64);

    for _ in 0..head.total_palettes {
        palnode.push(PaletteHeader::read(&mut reader));
    }

    file.seek(head.first_sprnode_offset as i64);

    for _ in 0..head.total_frames {
        sprnode.push(SpriteHeader::read(&mut reader));
    }

    for palette in palnode.iter() {
        let mut pal: Rc<Palette> = Rc::new(Palette::new(0));

        if palette.len == 0 { //linked pal
            pal = Rc::clone(&paldata[palette.linked as usize].pal);
        } else if palette.len > 0 { //"normal" pal
            let mut offset: usize = head.ldata_offset as usize;
            offset += palette.offset as usize;
            file.seek(offset as i64);

            let mut k = palette.numcols as usize;
            k = k * 4;
            let tmp_arr = reader.get_buffer(k);
            let mut tmp_arr_reader = BufferReader::new(&tmp_arr);
            k = k / 4;
            pal = matrix_to_pal(&mut tmp_arr_reader, k);
        }

        paldata.push(SffPal {
            pal: Rc::clone(&pal),
            itemno: palette.itemno as i32,
            groupno: palette.groupno as i32,
            is_used: false,
            usedby: -1,
            reserved: 0,
        });
    }

    //reading images
    for sprite in sprnode.iter() {
        let linked;
        let mut image = Rc::new(RefCell::new(RawImage::empty()));
        if sprite.len == 0 { //linked image
            linked = -1;
            image = Rc::clone(&sffdata[sprite.linked as usize].image);
        } else  { //"normal" image
            let mut offset: usize = 0;
            if sprite.flags == 0 {
                offset = head.ldata_offset as usize;
            }
            if sprite.flags != 0 {
                offset = head.tdata_offset as usize;
            }
            offset += sprite.offset as usize;
            file.seek(offset as i64);

            let mut tmp_arr = reader.get_buffer(sprite.len as usize);
            let mut tmp_reader = BufferReader::new(&tmp_arr);

            match sprite.fmt {
                2 => tmp_arr = decode_rle8(&mut tmp_reader),
                3 => tmp_arr = decode_rle5(&mut tmp_reader),
                4 => tmp_arr = decode_lz5(&mut tmp_reader),
                _ => ()
            };

            let expected_size = (sprite.w as usize * sprite.h as usize) as usize;
            let actual_size = tmp_arr.len();

            if expected_size != actual_size {
                return Err(DataError::new(format!("Image decoding failed. GroupNo={}. ImageNo={}", sprite.groupno, sprite.imageno)));
            }

            //adding image
            if  sprite.colordepth == 5 || sprite.colordepth == 8 {
                image = Rc::new(RefCell::new(RawImage {
                    w: sprite.w as usize,
                    h: sprite.h as usize,
                    pixels: Rc::new(tmp_arr),
                    color_table: Rc::clone(&paldata[sprite.palindex as usize].pal),
                }));
            }

            linked = -1;
        }

        sffdata.push(SffData {
            groupno: sprite.groupno as i32,
            imageno: sprite.imageno as i32,
            x: sprite.x as i32,
            y: sprite.y as i32,
            palindex: sprite.palindex as i32,
            image,
            linked,
        });
    }

    for a in 0..sffdata.len() {
        let b = sffdata[a].palindex as usize;
        if paldata[b].is_used == false {
            paldata[b].is_used = true;
            paldata[b].usedby = a as i32;
        }
    }

    file.close();

    Result::Ok(())
}
